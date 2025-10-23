#!/usr/bin/env bash
set -euo pipefail
ROOT="${ROOT:-/srv/project}"
ROLE="${ROLE:?video|audio|subtitle|compose のいずれか}"
mkdir -p "$ROOT/tasks/queue" "$ROOT/tasks/wip" "$ROOT/tasks/dead" "$ROOT/logs/nodes" "$ROOT/results/scenes"
HB="$ROOT/logs/heartbeat.$(hostname -s).$ROLE"
touch "$HB"

while :; do
  date +%s > "$HB"

  job=""
  for f in "$ROOT"/tasks/queue/*.json; do
    [[ -e "$f" ]] || break
    if jq -er --arg r "$ROLE" '.role==$r' "$f" >/dev/null 2>&1; then job="$f"; break; fi
  done
  if [[ -z "$job" ]]; then sleep 10; continue; fi

  base=$(basename "$job"); tgt="$ROOT/tasks/wip/$base"
  mv "$job" "$tgt" 2>/dev/null || continue

  id=$(jq -r '.id' "$tgt"); scene=$(jq -r '.scene' "$tgt"); llm=$(jq -r '.llm' "$tgt")
  case "$llm" in
    14b) EP="http://192.168.3.101:9201";;
    7b)  EP="http://192.168.3.101:9202";;
    3b)  EP="http://192.168.3.101:9203";;
    *)   EP="http://192.168.3.101:9200";;
  esac

  rc=0
  case "$ROLE" in
    video)    ./pipelines/video_generate.sh   "$tgt" "$EP" || rc=$?;;
    audio)    ./pipelines/audio_tts.sh        "$tgt"        || rc=$?;;
    subtitle) ./pipelines/subtitle_make.sh    "$tgt"        || rc=$?;;
    compose)  ./pipelines/compose_edit.sh     "$tgt"        || rc=$?;;
  esac

  if (( rc != 0 )); then
    tmp=$(mktemp); jq '.retry_count=(.retry_count//0)+1' "$tgt" > "$tmp" && mv "$tmp" "$tgt"
    r=$(jq -r '.retry_count//0' "$tgt"); m=$(jq -r '.retry_max' "$tgt")
    if (( r > m )); then mv "$tgt" "$ROOT/tasks/dead/$base"; echo "$(date -Iseconds) $ROLE $id FAIL" >> "$ROOT/logs/nodes/fail.log"; fi
    continue
  fi

  echo "$(date -Iseconds) $ROLE $id OK" >> "$ROOT/logs/nodes/done.log"
done
