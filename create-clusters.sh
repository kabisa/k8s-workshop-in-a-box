#!/usr/bin/env bash
set -e
if [ "$#" -ne 1 ]; then
    echo "Missing number of clusters to create"
    exit 1
fi

for i in {1..$(seq $1)}
do
  USER=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)
  $(dirname $0)/create-cluster.sh "$USER"

  echo "$USER" >> /home/icanhazcluster/clusters.txt
done

chown icanhazcluster:icanhazcluster /home/icanhazcluster/clusters.txt
