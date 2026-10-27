#!/usr/bin/env bash
# Copia os dados do blue para o green e liga a replicação blue -> green via GTID
source "$(dirname "$0")/lib.sh"
mkdir -p .work

step "Gerando dump consistente do blue (sem lock, com a posição GTID)"
docker compose exec -T blue mariadb-dump -uroot -p"$ROOT_PW" \
  --single-transaction --gtid --master-data=2 --databases lab >.work/blue.sql
gtid=$(grep -oP "gtid_slave_pos='\K[^']*" .work/blue.sql | head -1)
[[ -n $gtid ]] || die "posição GTID não encontrada no dump"
echo "Dump feito na posição GTID $gtid"

step "Restaurando no green sem gravar no binlog dele"
{
  echo "SET SESSION sql_log_bin = 0;"
  cat .work/blue.sql
} | docker compose exec -T green mariadb -uroot -p"$ROOT_PW"

step "Ligando a replicação blue -> green a partir de $gtid"
sql green "
  SET GLOBAL gtid_slave_pos = '$gtid';
  CHANGE MASTER TO
    MASTER_HOST = 'blue',
    MASTER_USER = '$REPL_USER',
    MASTER_PASSWORD = '$REPL_PW',
    MASTER_USE_GTID = slave_pos;
  START REPLICA;
"
sleep 2
./scripts/lag.sh green blue --once
