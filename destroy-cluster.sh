#!/usr/bin/env bash
set -e
USER="$1"

kind delete cluster --name $USER
userdel "$USER" --remove