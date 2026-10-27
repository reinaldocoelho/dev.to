#!/usr/bin/env bash
# Compara o conteúdo da tabela nos dois servidores e procura buracos nas escritas da aplicação
source "$(dirname "$0")/lib.sh"

checksum="SELECT COUNT(*), BIT_XOR(CRC32(CONCAT_WS('#', id, seq, source, created_at))) FROM lab.writes"
gaps="SELECT COUNT(*), MAX(seq) FROM lab.writes WHERE source IN ('blue', 'green')"

printf '%-6s %-22s %s\n' servidor 'linhas / checksum' 'escritas da app / maior seq'
for host in blue green; do
  printf '%-6s %-22s %s\n' "$host" "$(sql "$host" "$checksum" | tr '\t' ' ')" "$(sql "$host" "$gaps" | tr '\t' ' ')"
done
