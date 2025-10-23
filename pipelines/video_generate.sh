#!/usr/bin/env bash
set -euo pipefail
TASK="${1:?usage: video_generate.sh <task.json> [LLM_EP]}"
EP="${2:-http://192.168.3.101:9202}"
ROOT="${ROOT:-/srv/project}"
ID="$(jq -r .id "$TASK")"
OUTDIR="$ROOT/results/scenes/$ID"
mkdir -p "$OUTDIR"
DUR="$(jq -r '.inputs.duration_sec // 5' "$TASK" 2>/dev/null || echo 5)"
TXT="$(jq -r '.inputs.prompt // env.ID' "$TASK" 2>/dev/null || echo "$ID")"

if ffmpeg -hide_banner -encoders 2>/dev/null | grep -q h264_nvenc; then
  CODEC=(-c:v h264_nvenc -preset p5 -rc:v vbr -cq:v 19 -b:v 10M -maxrate:v 20M -bufsize:v 40M)
else
  CODEC=(-c:v libx264 -b:v 10M)  # フォールバック
fi

ffmpeg -hide_banner -loglevel error -f lavfi -i testsrc2=size=1920x1080:rate=30 -t "$DUR" \
  -vf "drawtext=text='${TXT}':x=(w-text_w)/2:y=(h-text_h)/2:fontsize=48:fontcolor=white:box=1:boxcolor=black@0.5" \
  "${CODEC[@]}" -pix_fmt yuv420p -movflags +faststart -y "$OUTDIR/proxy.mp4"

jq -n --arg id "$ID" '{ok:true,id:$id}' > "$OUTDIR/result.json"
