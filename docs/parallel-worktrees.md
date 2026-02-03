# Parallel Development with git worktree

## 目的
- 1つのリポジトリで複数タスクを同時進行する
- ただし衝突を避けるため、作業ディレクトリを分離する

## 用語（抽象化）
- [並列開発]=複数タスクの同時進行
- [作業ツリー]=worktree
- [統合端末]=メインリポジトリ端末

## 推奨フロー

1) 統合端末で計画
- `/exec-plan` で plan.json を作成
- `/worktree-init <plan>` で worktree を作る

2) 各 worktree 端末で実装
- `cd .worktrees/<task>`
- `claude` を起動
- `/tdd-cycle` → 実装 → `/exec-verify`

3) 統合端末でマージ・衝突解消
- `git fetch` / `git merge` / `git rebase` などはチーム規約に合わせる
- 衝突が多い場合は plan を見直し、同時編集を避ける

## 規約
- worktree は `.worktrees/` 配下に作る（生成物は git 管理しない）
- 1 worktree = 1責務（小さく保つ）
- 破壊的操作（worktree remove）は必ずユーザー確認

## 片付け
- `python3 scripts/worktrees/cleanup_worktrees.py --yes`
- `git worktree prune`
