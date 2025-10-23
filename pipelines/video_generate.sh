#!/usr/bin/env bash
set -euo pipefail
TASK="${1:?usage: video_generate.sh <task.json> [LLM_EP]}"
EP="${2:-http://192.168.3.101:9202}"
ROOT="${ROOT:-/srv/project}"
ID="$(jq -r .id "$TASK")"
OUTDIR="$ROOT/results/scenes/$ID"
mkdir -p "$OUTDIR"

# 入力
DUR="$(jq -r '.inputs.duration_sec // 5' "$TASK" 2>/dev/null || echo 5)"
TXT="$(jq -r '.inputs.prompt // env.ID' "$TASK" 2>/dev/null || echo "$ID")"

# 1080p/30fpsの実mp4を生成
ffmpeg -hide_banner -loglevel error -f lavfi -i testsrc2=size=1920x1080:rate=30 \
  -t "$DUR" -vf "drawtext=text='${TXT}':x=(w-text_w)/2:y=(h-text_h)/2:fontsize=48:fontcolor=white:box=1:boxcolor=black@0.5" \
  -c:v libx264 -pix_fmt yuv420p -movflags +faststart -y "$OUTDIR/proxy.mp4"

jq -n --arg id "$ID" '{ok:true,id:$id}' > "$OUTDIR/result.json"
