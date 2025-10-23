#!/usr/bin/env bash
set -euo pipefail
TASK="${1:-}"
ROOT="${ROOT:-/srv/project}"
OUTDIR="$ROOT/delivery/final"
mkdir -p "$OUTDIR" "$ROOT/results/scenes"

# まず 3070-2 から結果を同期（鍵配布済み前提）
SRC_USER="${SRC_USER:-aiuser}"
SRC_HOST="${SRC_HOST:-192.168.3.102}"   # videoノード
SRC_DIR="${SRC_DIR:-/srv/project/results/scenes/}"
rsync -a --delete ${SRC_USER}@${SRC_HOST}:"${SRC_DIR}" "$ROOT/results/scenes/" || true

# 入力収集
LIST="$(mktemp)"
find "$ROOT/results/scenes" -maxdepth 2 -type f -name proxy.mp4 \
 | sort | sed "s/^/file '/; s/$/'/" > "$LIST"

[ -s "$LIST" ] || { echo "no inputs"; exit 2; }

# 1080pへ結合
TS=$(date +%Y%m%d_%H%M%S)
OUT="$OUTDIR/video_$TS.mp4"
ffmpeg -hide_banner -loglevel error -f concat -safe 0 -i "$LIST" \
  -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
  -r 30 -c:v libx264 -b:v 16M -pix_fmt yuv420p -movflags +faststart -y "$OUT"

ln -sf "$(basename "$OUT")" "$OUTDIR/latest.mp4"
jq -n --arg out "$OUT" --arg ts "$TS" '{ok:true, output:$out, timestamp:$ts}'
