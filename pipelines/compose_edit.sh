#!/usr/bin/env bash
set -euo pipefail
TASK="$1"; ROOT="${ROOT:-/srv/project}"
# ここで results/scenes/*/proxy.mp4 を結合する実処理に差し替える
echo "compose stub" > "$ROOT/delivery_final.mp4"
exit 0
