#!/usr/bin/env bash

while read p; do
  echo "starting $p"
  docker start $p-control-plane $p-worker $p-worker2
done < /home/icanhazcluster/clusters.txt

echo "done"
