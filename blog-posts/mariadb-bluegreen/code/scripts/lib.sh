# Funções compartilhadas pelos scripts do laboratório (executar sempre a partir da pasta code/)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

ROOT_PW=root
REPL_USER=repl
REPL_PW=repl

# sql <servidor> <comando>: executa como root e devolve só os valores
sql() {
  docker compose exec -T "$1" mariadb -uroot -p"$ROOT_PW" -N -B -e "$2"
}

# replica_status <servidor>: saída do SHOW REPLICA STATUS em formato vertical
replica_status() {
  docker compose exec -T "$1" mariadb -uroot -p"$ROOT_PW" -e 'SHOW REPLICA STATUS\G'
}

# field <saida-do-status> <campo>: extrai um campo do SHOW REPLICA STATUS
field() {
  awk -F': ' -v key="$2" '$1 ~ "^ *"key"$" { print $2 }' <<<"$1"
}

step() { printf '\n\033[1m[%s] %s\033[0m\n' "$(date +%T.%3N)" "$*"; }
die() {
  printf '\033[31mABORTADO: %s\033[0m\n' "$*" >&2
  exit 1
}
