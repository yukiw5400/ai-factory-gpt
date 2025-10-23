#!/usr/bin/env bash
set -euo pipefail
TASK="$1"; EP="${2:-http://192.168.3.101:9202}"
ROOT="${ROOT:-/srv/project}"
id=$(jq -r '.id' "$TASK")
out="$ROOT/results/scenes/$id"
mkdir -p "$out"
echo "video stub via $EP" > "$out/proxy.mp4"
jq -n --arg id "$id" --argjson d 1.0 '{id:$id,ok:true,duration_sec:$d}' > "$out/result.json"
