#!/usr/bin/env bash
set -euo pipefail
ROOT=${1:-/Volumes/project}
now=$(date +%s)
for hb in "$ROOT"/logs/heartbeat.*; do
  [[ -e "$hb" ]] || continue
  ts=$(cat "$hb" 2>/dev/null || echo 0); age=$((now-ts))
  (( age>300 )) && echo "心拍停止: $(basename "$hb") ${age}s"
done
find "$ROOT/tasks/wip" -type f -mmin +90 -print | sed 's/^/滞留: /' || true
[[ -f "$ROOT/logs/nodes/fail.log" ]] && tail -n3 "$ROOT/logs/nodes/fail.log" || true
