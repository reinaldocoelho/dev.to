#!/usr/bin/env bash
# Uso: switchover.sh <primario-atual> <novo-primario> [reverse|readonly]
# Promove a réplica a primário e aponta o DNS para ela. Depois, o antigo primário:
#   reverse  (padrão) vira réplica do novo: rollback sem perda = mesmo script invertido
#   readonly fica parado e somente leitura, como no RDS: rollback via emergency-rollback.sh
source "$(dirname "$0")/lib.sh"
usage="uso: switchover.sh <primario-atual> <novo-primario> [reverse|readonly]"
old=${1:?$usage}
new=${2:?$usage}
mode=${3:-reverse}
[[ $mode == reverse || $mode == readonly ]] || die "$usage"
max_lag=${MAX_LAG:-1}

step "1. Guardrails"
status=$(replica_status "$new")
[[ $(field "$status" Master_Host) == "$old" ]] || die "$new não replica de $old"
[[ $(field "$status" Slave_IO_Running) == Yes && $(field "$status" Slave_SQL_Running) == Yes ]] ||
  die "replicação parada em $new"
lag=$(field "$status" Seconds_Behind_Master)
[[ $lag != NULL && $lag -le $max_lag ]] || die "lag de ${lag}s em $new (máximo ${max_lag}s)"
long_trx=$(sql "$old" "SELECT COUNT(*) FROM information_schema.innodb_trx
                       WHERE trx_started < NOW() - INTERVAL 10 SECOND")
[[ $long_trx -eq 0 ]] || die "$long_trx transação(ões) longa(s) em $old"
echo "Replicação saudável, lag ${lag}s, sem transações longas"

step "2. Bloqueando escritas em $old"
start=$(date +%s%N)
sql "$old" "SET GLOBAL read_only = ON"
for id in $(sql "$old" "SELECT id FROM information_schema.processlist WHERE user = 'app'"); do
  sql "$old" "KILL CONNECTION $id" || true
done

step "3. Aguardando $new aplicar a última transação de $old"
pos=$(sql "$old" "SELECT @@gtid_binlog_pos")
if [[ $(sql "$new" "SELECT MASTER_GTID_WAIT('$pos', 30)") != 0 ]]; then
  sql "$old" "SET GLOBAL read_only = OFF"
  die "$new não alcançou $pos em 30s; escritas liberadas novamente em $old"
fi
echo "$new está na posição $pos"

step "4. Promovendo $new a primário"
sql "$new" "STOP REPLICA; RESET REPLICA ALL; SET GLOBAL read_only = OFF"

step "5. Apontando o DNS para $new"
./scripts/set-dns.sh "$new"
elapsed=$((($(date +%s%N) - start) / 1000000))

if [[ $mode == readonly ]]; then
  step "6. Mantendo $old parado e somente leitura na posição $pos"
  step "Switchover concluído: escritas bloqueadas por ${elapsed}ms + TTL do DNS"
  exit 0
fi

step "6. Transformando $old em réplica de $new"
sql "$old" "
  SET GLOBAL gtid_slave_pos = @@gtid_binlog_pos;
  CHANGE MASTER TO
    MASTER_HOST = '$new',
    MASTER_USER = '$REPL_USER',
    MASTER_PASSWORD = '$REPL_PW',
    MASTER_USE_GTID = slave_pos;
  START REPLICA;
"
sleep 2
./scripts/lag.sh "$old" "$new" --once

step "Switchover concluído: escritas bloqueadas por ${elapsed}ms + TTL do DNS"
