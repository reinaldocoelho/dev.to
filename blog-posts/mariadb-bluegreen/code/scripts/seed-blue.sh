#!/usr/bin/env bash
# Cria a tabela usada pela "aplicação" e uma carga inicial no banco em produção (blue)
source "$(dirname "$0")/lib.sh"

sql blue "
  CREATE TABLE IF NOT EXISTS lab.writes (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    seq        INT         NOT NULL,
    source     VARCHAR(64) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
  );
  INSERT INTO lab.writes (seq, source) SELECT seq, 'seed' FROM seq_1_to_100000;
"
sql blue "SELECT COUNT(*) AS linhas, @@gtid_binlog_pos AS gtid FROM lab.writes"
