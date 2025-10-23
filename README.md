# ai-factory-gpt
目的: n8nなしで「ファイルキュー＋常駐ワーカー＋HAProxy経由LLM」で15分1080p動画を1本通す最小構成。

## 使い方（要約）
- Macでシーン別の task.json を共有フォルダの tasks/queue に置く
- 各ノードの systemd 常駐ワーカーが自動取得→処理→results に返す
- 失敗は自動再試行。上限超えは dead へ退避
- LLMは HAProxy 9201(14B)/9202(7B)/9203(3B)/9200(router) を使用

## 重要
- pipelines/* はダミー。実機の生成スクリプトに差し替える
- worker.sh は ROOT=/srv/project を既定。必要なら環境変数で変更
