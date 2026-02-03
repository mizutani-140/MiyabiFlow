---
description: "現在の worktree 状況とタスク進捗ファイルを表示する"
allowed-tools: Bash(git*), Bash(ls*), Bash(cat*), Read
---

# /worktree-status — worktree の状態確認

!git worktree list --porcelain
!ls -la .ai/worktrees || true
!cat .ai/worktrees/TERMINAL_ASSIGNMENTS.md 2>/dev/null || true
