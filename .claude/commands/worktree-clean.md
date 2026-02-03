---
description: "生成した worktree を一括削除（安全ガード付き）し、git worktree prune を実行する"
allowed-tools: Bash(python3 scripts/worktrees/*), Bash(git*), Read
---

# /worktree-clean — worktree を掃除する（破壊的操作）

注意：このコマンドは worktree を削除します。実行前にユーザー確認を推奨。

!python3 scripts/worktrees/cleanup_worktrees.py --yes
!git worktree prune
