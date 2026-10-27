#!/usr/bin/env bash
# Aponta db.lab.internal para o servidor informado (o CoreDNS relê o arquivo a cada 1s)
source "$(dirname "$0")/lib.sh"
declare -A ip=([blue]=172.30.0.11 [green]=172.30.0.12)
target=${1:?uso: set-dns.sh <blue|green>}

printf '%s db.lab.internal\n' "${ip[$target]}" >dns/hosts
echo "db.lab.internal -> $target (${ip[$target]}), TTL 5s"
