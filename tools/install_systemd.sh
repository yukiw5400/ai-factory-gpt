#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/env.sh"
pushd systemd >/dev/null
scp ai-worker-video.service     ${SSH_USER}@"$NODE_VIDEO":/tmp/
scp ai-worker-audio.service     ${SSH_USER}@"$NODE_AUDIO":/tmp/
scp ai-worker-subtitle.service  ${SSH_USER}@"$NODE_SUB":/tmp/
scp ai-worker-compose.service   ${SSH_USER}@"$NODE_COMPOSE":/tmp/

ssh ${SSH_USER}@"$NODE_VIDEO"   "sudo mv /tmp/ai-worker-video.service    /etc/systemd/system/ && sudo systemctl daemon-reload && sudo systemctl enable --now ai-worker-video"
ssh ${SSH_USER}@"$NODE_AUDIO"   "sudo mv /tmp/ai-worker-audio.service    /etc/systemd/system/ && sudo systemctl daemon-reload && sudo systemctl enable --now ai-worker-audio"
ssh ${SSH_USER}@"$NODE_SUB"     "sudo mv /tmp/ai-worker-subtitle.service /etc/systemd/system/ && sudo systemctl daemon-reload && sudo systemctl enable --now ai-worker-subtitle"
ssh ${SSH_USER}@"$NODE_COMPOSE" "sudo mv /tmp/ai-worker-compose.service  /etc/systemd/system/ && sudo systemctl daemon-reload && sudo systemctl enable --now ai-worker-compose"
popd >/dev/null
