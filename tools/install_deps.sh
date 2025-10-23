#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/env.sh"
for H in "$NODE_VIDEO" "$NODE_AUDIO" "$NODE_SUB" "$NODE_COMPOSE"; do
  ssh ${SSH_USER}@"$H" "sudo apt-get update -y &&
    sudo apt-get install -y jq ffmpeg &&
    sudo mkdir -p $ROOT && sudo chown -R ${SSH_USER}:${SSH_USER} $ROOT &&
    mkdir -p $ROOT/{tasks/queue,tasks/wip,tasks/dead,results/scenes,logs/nodes}"
done
