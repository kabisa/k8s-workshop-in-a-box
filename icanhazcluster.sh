#!/usr/bin/env bash
CLUSTER=$((
  flock -x 200
  CLUSTER=$(head -n 1 ~/clusters.txt)
  sed -i '1d' ~/clusters.txt
  echo $CLUSTER
) 200>/tmp/clusters-lock)

if [ -n "$CLUSTER" ]; then
  echo -e "Cluster available! 🙌\n"
  
  echo "Use the following command to SSH into your shell and start using kubectl:"
  echo -e "$(tput setaf 2)ssh $CLUSTER@$(curl -s v4.icanhazip.com)$(tput sgr0)\n"
else
  echo -e "$(tput setaf 1)Uh oh, no more clusters available!$(tput sgr0) 😱\n"
  exit 1
fi
