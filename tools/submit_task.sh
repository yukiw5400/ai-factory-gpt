#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/env.sh"
F="${1:?usage: submit_task.sh <task.json>}"
ROLE=$(jq -r .role "$F")
case "$ROLE" in
  video)    HOST="$NODE_VIDEO"   ;;
  audio)    HOST="$NODE_AUDIO"   ;;
  subtitle) HOST="$NODE_SUB"     ;;
  compose)  HOST="$NODE_COMPOSE" ;;
  *) echo "unknown role: $ROLE"; exit 2;;
esac
scp "$F" ${SSH_USER}@"$HOST":"$ROOT/tasks/queue/"
echo "queued: $F -> $HOST"
