#!/usr/bin/env bash
# Uso: cleanup.sh <servidor-antigo>
# Desfaz a replicação de volta (se houver) e desliga o servidor antigo (o volume é mantido para auditoria)
source "$(dirname "$0")/lib.sh"
old=${1:?uso: cleanup.sh <servidor-antigo>}

if [[ -n $(replica_status "$old") ]]; then
  step "Desligando a replicação em $old"
  sql "$old" "STOP REPLICA; RESET REPLICA ALL"
fi

step "Parando o container $old"
docker compose stop "$old"
echo "Para apagar de vez (inclusive os dados): docker compose rm -v $old"
