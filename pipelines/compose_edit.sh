#!/usr/bin/env bash
set -euo pipefail
TASK="${1:-}"
ROOT="${ROOT:-/srv/project}"
OUTDIR="$ROOT/delivery/final"
mkdir -p "$OUTDIR" "$ROOT/results/scenes"

SRC_USER="${SRC_USER:-aiuser}"
SRC_HOST="${SRC_HOST:-192.168.3.102}"   # videoノード
SRC_DIR="${SRC_DIR:-/srv/project/results/scenes/}"
rsync -a --delete ${SRC_USER}@${SRC_HOST}:"${SRC_DIR}" "$ROOT/results/scenes/" || true

LIST="$(mktemp)"
find "$ROOT/results/scenes" -maxdepth 2 -type f -name proxy.mp4 -size +100k \
 | sort | sed "s/^/file '/; s/$/'/" > "$LIST"
[ -s "$LIST" ] || { echo "no inputs"; exit 2; }

TS=$(date +%Y%m%d_%H%M%S)
OUT="$OUTDIR/video_$TS.mp4"

if ffmpeg -hide_banner -encoders 2>/dev/null | grep -q h264_nvenc; then
  CODEC=(-c:v h264_nvenc -preset p5 -rc:v vbr -cq:v 19 -b:v 16M -maxrate:v 32M -bufsize:v 64M)
else
  CODEC=(-c:v libx264 -b:v 16M)
fi

ffmpeg -hide_banner -loglevel error -f concat -safe 0 -i "$LIST" \
  -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
  -r 30 "${CODEC[@]}" -pix_fmt yuv420p -movflags +faststart -y "$OUT"

ln -sf "$(basename "$OUT")" "$OUTDIR/latest.mp4"
jq -n --arg out "$OUT" --arg ts "$TS" '{ok:true, output:$out, timestamp:$ts}'
