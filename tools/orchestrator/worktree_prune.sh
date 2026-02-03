#!/usr/bin/env bash
set -euo pipefail

# Prune stale worktrees and remove directories under .worktrees that are no longer registered.

git worktree prune

if [[ -d .worktrees ]]; then
  for d in .worktrees/*; do
    [[ -d "$d" ]] || continue
    if ! git worktree list --porcelain | grep -q "worktree $(cd "$d" && pwd)"; then
      echo "Removing unregistered worktree dir: $d" >&2
      rm -rf "$d"
    fi
  done
fi
