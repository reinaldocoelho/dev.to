-- Criado localmente nos dois servidores (sem ir para o binlog):
-- quem for primário precisa aceitar a conexão de replicação do outro.
SET SESSION sql_log_bin = 0;
CREATE USER 'repl'@'%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'%';
