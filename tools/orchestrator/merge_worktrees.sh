#!/usr/bin/env bash
set -euo pipefail

# Merge multiple task branches into current branch in a controlled order.
# Usage:
#   ./tools/orchestrator/merge_worktrees.sh T1-auth-middleware T2-add-tests

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repository." >&2
  exit 1
fi

if [[ "$#" -lt 1 ]]; then
  echo "Usage: $0 <T<ID>-slug> [more...]" >&2
  exit 1
fi

for task in "$@"; do
  branch="task/${task}"
  echo "Merging $branch ..." >&2
  git merge --no-ff "$branch" -m "merge: ${task}"
done

echo "Merge complete. Run: make ci" >&2
