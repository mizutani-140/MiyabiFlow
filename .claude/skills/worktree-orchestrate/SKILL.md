---
name: worktree-orchestrate
description: "plan.json をもとに git worktree を作成・管理し、並列開発の端末割当を確定する。"
argument-hint: "[.ai/plans/..._plan.json]"
allowed-tools: Bash(git*), Bash(python3 scripts/worktrees/*), Read, Write
---

# [目的]
[並列開発] を安全に運用するため、worktree を規約どおりに作成し、後片付けまで含めて管理する。

# [手順]
1. plan.json を読み、タスクごとの worktree 名・ブランチ規約を確認
2. `scripts/worktrees/apply_plan.py` を実行して worktree を作成
3. `.ai/worktrees/TERMINAL_ASSIGNMENTS.md` を生成／更新
4. worktree ごとに「作業開始コマンド」と「品質ゲート」を明記
5. 破棄が必要なら `scripts/worktrees/cleanup_worktrees.py` を使う（ユーザー確認推奨）

# [規約]
- worktree の物理配置は `.worktrees/[name]` 配下（`.gitignore` 済み）
- ブランチ名は `ai/[plan_id]/[worktree]` を基本
- 破壊的操作（remove/prune）は必ずユーザーに一言確認

# [完了条件]
- `git worktree list` に必要な worktree が揃っている
- TERMINAL_ASSIGNMENTS.md が最新で、端末でそのまま実行できる
