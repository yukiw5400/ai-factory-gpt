#!/usr/bin/env bash
set -euo pipefail
TASK="$1"; ROOT="${ROOT:-/srv/project}"
id=$(jq -r '.id' "$TASK"); out="$ROOT/results/scenes/$id"; mkdir -p "$out"
echo "audio stub" > "$out/audio.txt"
exit 0
