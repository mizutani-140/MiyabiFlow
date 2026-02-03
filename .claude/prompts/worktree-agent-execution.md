# [並列作業ツリー] 実行プロトコル（参考）

## 原則
- 1タスク=1 worktree
- worktreeは `.worktrees/<task>` に作る
- 競合しやすいファイルは同時に触らない

## 作業手順（各ターミナル/ペイン）
1. `cd .worktrees/<task>`
2. `make test` がREDになるテストを作る
3. 最小実装でGREEN
4. `make ci` が通るまで直す
5. `git commit -m "<task>: <summary>"`
6. PR用ブランチを push

## 統合
- 統合worktree（main）で `tools/orchestrator/merge_worktrees.sh` を順に実行
