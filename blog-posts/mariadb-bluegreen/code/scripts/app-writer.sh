#!/usr/bin/env bash
# Simula uma aplicação: abre uma conexão nova a cada escrita (resolvendo o DNS toda vez)
# e repete a mesma escrita até ela ser aceita, como faria um retry de verdade.
seq=1
while true; do
  if out=$(mariadb -h db.lab.internal -u app -papp lab -N -B --connect-timeout=2 \
    -e "INSERT INTO writes (seq, source) VALUES ($seq, @@hostname); SELECT @@hostname, @@version;" 2>&1); then
    echo "$(date +%T.%3N) OK   seq=$seq -> ${out//$'\t'/ }"
    seq=$((seq + 1))
  else
    echo "$(date +%T.%3N) FAIL seq=$seq -> $out"
  fi
  sleep 0.2
done
