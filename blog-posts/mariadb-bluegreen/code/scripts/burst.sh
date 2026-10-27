#!/usr/bin/env bash
# Gera uma transação grande no primário para provocar lag na réplica
source "$(dirname "$0")/lib.sh"
primary=${1:-blue}

sql "$primary" "INSERT INTO lab.writes (seq, source) SELECT seq, 'burst' FROM seq_1_to_1000000"
echo "1.000.000 de linhas gravadas em $primary"
