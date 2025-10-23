#!/usr/bin/env bash
set -euo pipefail
ID="${1:?usage: new_scene.sh <scene-id> <prompt>}"
PROMPT="${2:-テスト映像。10秒。}"
cat > "examples/tasks/${ID}.video.json" <<JSON
{"id":"${ID}","scene":"${ID}","role":"video","deadline_sec":5400,"retry_max":2,"llm":"7b",
 "inputs":{"prompt":"${PROMPT}"},"notes":"auto"}
JSON
echo "created: examples/tasks/${ID}.video.json"
