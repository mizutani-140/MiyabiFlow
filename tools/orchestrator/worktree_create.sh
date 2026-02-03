#!/usr/bin/env bash
set -euo pipefail

# Create a git worktree for a task.
# Usage:
#   ./tools/orchestrator/worktree_create.sh T1-auth-middleware
#
# Convention:
#   branch: task/<worktree>
#   path:   .worktrees/<worktree>

TASK="${1:-}"
if [[ -z "$TASK" ]]; then
  echo "Usage: $0 <T<ID>-slug>" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repository." >&2
  exit 1
fi

BRANCH="task/${TASK}"
PATH_DIR=".worktrees/${TASK}"

mkdir -p .worktrees

if [[ -d "$PATH_DIR" ]]; then
  echo "Worktree already exists: $PATH_DIR" >&2
  exit 0
fi

echo "Creating worktree: $PATH_DIR on branch $BRANCH" >&2
git worktree add -b "$BRANCH" "$PATH_DIR"

# Add a task file if absent
if [[ ! -f "$PATH_DIR/TASK.md" ]]; then
  cat > "$PATH_DIR/TASK.md" <<'MD'
# TASK

- ID: <fill>
- Goal: <fill>
- Owner: [AIコーディングエージェントA] or [AIコーディングエージェントB]
- DoD:
  - [ ] テスト追加（Red→Green→Refactor）
  - [ ] make ci 成功
  - [ ] PR説明がある（何を/なぜ/検証）

## Notes
MD
fi

echo "Done. Next:" >&2
echo "  cd $PATH_DIR" >&2
echo "  claude" >&2
