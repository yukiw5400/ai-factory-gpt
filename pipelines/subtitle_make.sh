#!/usr/bin/env bash
set -euo pipefail
TASK="$1"; ROOT="${ROOT:-/srv/project}"
id=$(jq -r '.id' "$TASK"); out="$ROOT/results/scenes/$id"; mkdir -p "$out"
echo "1\n00:00:00,000 --> 00:00:02,000\nSUBTITLE STUB" > "$out/subtitle.srt"
exit 0
