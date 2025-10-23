1) tools/env.sh のIPとユーザーを環境に合わせて直す
2) tools/install_deps.sh → tools/deploy_nodes.sh → tools/install_systemd.sh を順に実行
3) LLM疎通: 192.168.3.101:9201/9202/9203/9200 で /v1/models が 200
4) タスクを tasks/queue に置くと自動処理→results/scenes/<id> に出力
5) 失敗は自動再試行。上限超えは tasks/dead を確認
6) tools/health_check.sh で心拍/滞留/失敗ログを確認
