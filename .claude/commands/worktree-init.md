---
description: "plan.json を読み取り、git worktree を作成し、端末割当（TERMINAL_ASSIGNMENTS.md）を更新する"
argument-hint: "<.ai/plans/..._plan.json>"
allowed-tools: Bash(git*), Bash(python3 scripts/worktrees/*), Read, Write
---

# /worktree-init — plan から worktree を作る

!python3 scripts/worktrees/apply_plan.py --plan "$ARGUMENTS"
