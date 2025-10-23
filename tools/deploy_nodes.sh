#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/env.sh"
for H in "$NODE_VIDEO" "$NODE_AUDIO" "$NODE_SUB" "$NODE_COMPOSE"; do
  rsync -av --delete bin pipelines schemas ${SSH_USER}@"$H":"$ROOT"/
done
