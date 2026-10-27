#!/usr/bin/env bash
# Uso: lag.sh <replica> <primario> [--once]
# Mostra o lag em segundos e compara as posições GTID dos dois lados
source "$(dirname "$0")/lib.sh"
replica=${1:-green}
primary=${2:-blue}

while true; do
  status=$(replica_status "$replica")
  primary_pos=$(sql "$primary" "SELECT @@gtid_binlog_pos")
  replica_pos=$(sql "$replica" "SELECT @@gtid_slave_pos")
  [[ $primary_pos == "$replica_pos" ]] && sync="EM DIA" || sync="ATRASADO"

  printf '%s IO=%s SQL=%s lag=%ss | %s=%s %s=%s | %s\n' "$(date +%T)" \
    "$(field "$status" Slave_IO_Running)" "$(field "$status" Slave_SQL_Running)" \
    "$(field "$status" Seconds_Behind_Master)" \
    "$primary" "$primary_pos" "$replica" "$replica_pos" "$sync"

  [[ ${3:-} == --once ]] && break
  sleep 1
done
