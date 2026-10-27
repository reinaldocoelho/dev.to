#!/usr/bin/env bash
# Uso: emergency-rollback.sh <primario-atual> <antigo-primario>
# Rollback quando o switchover foi feito em modo readonly (sem replicação de volta):
# o antigo primário volta a receber escritas, mas tudo que foi gravado no atual depois da troca
# NÃO está nele. O atual fica somente leitura para que essas transações possam ser recuperadas.
source "$(dirname "$0")/lib.sh"
usage="uso: emergency-rollback.sh <primario-atual> <antigo-primario>"
current=${1:?$usage}
old=${2:?$usage}

step "1. Bloqueando escritas em $current"
sql "$current" "SET GLOBAL read_only = ON"
for id in $(sql "$current" "SELECT id FROM information_schema.processlist WHERE user = 'app'"); do
  sql "$current" "KILL CONNECTION $id" || true
done

step "2. Medindo o que ficará para trás"
old_pos=$(sql "$old" "SELECT @@gtid_binlog_pos")
current_pos=$(sql "$current" "SELECT @@gtid_binlog_pos")
echo "$old parou em:      $old_pos"
echo "$current chegou em: $current_pos"
if [[ $old_pos != "$current_pos" ]]; then
  printf '\033[33mAs transações depois de %s existem só em %s e precisam ser reconciliadas manualmente.\033[0m\n' \
    "$old_pos" "$current"
fi

step "3. Liberando escritas em $old"
sql "$old" "SET GLOBAL read_only = OFF"

step "4. Apontando o DNS para $old"
./scripts/set-dns.sh "$old"

step "Rollback concluído. Não reaproveite $current como réplica: recrie-o do zero (create-green.sh)."
