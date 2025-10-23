#!/usr/bin/env bash
set -euo pipefail
TASK="$1"
ROOT="${ROOT:-/srv/project}"
OUTDIR="$ROOT/delivery/final"
mkdir -p "$OUTDIR"

# 結合対象を集める（proxy.mp4 があるシーンをID昇順）
LIST="$(mktemp)"
find "$ROOT/results/scenes" -maxdepth 2 -type f -name proxy.mp4 \
 | sort | sed "s/^/file '/; s/$/'/" > "$LIST"

# 何も無ければ失敗
[ -s "$LIST" ] || { echo "no inputs"; exit 2; }

# 1080pで結合（縦横比保持＋黒余白、faststart）
TS=$(date +%Y%m%d_%H%M%S)
OUT="$OUTDIR/video_$TS.mp4"
ffmpeg -hide_banner -loglevel error -f concat -safe 0 -i "$LIST" \
  -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
  -r 30 -c:v libx264 -b:v 16M -pix_fmt yuv420p -movflags +faststart -y "$OUT"

ln -sf "$(basename "$OUT")" "$OUTDIR/latest.mp4"

# 結果JSON
jq -n --arg out "$OUT" --arg ts "$TS" '{ok:true, output:$out, timestamp:$ts}'
