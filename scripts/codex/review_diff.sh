#!/usr/bin/env bash
set -euo pipefail

FOCUS="${1:-general}"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

mkdir -p .ai/tmp

# Prefer staged diff if present, else working tree diff
if git diff --cached --quiet; then
  git diff > .ai/tmp/diff.patch
else
  git diff --cached > .ai/tmp/diff.patch
fi

if [[ ! -s .ai/tmp/diff.patch ]]; then
  echo "[codex] No diff found (working tree clean?)." >&2
  exit 0
fi

echo "[codex] Diff written to .ai/tmp/diff.patch" >&2
echo "[codex] Running: codex exec (focus: $FOCUS)" >&2

codex exec "You are [AIコーディングエージェントB]. Review the changes in this repo. Focus: ${FOCUS}.

Follow AGENTS.md review guidelines.

Read .ai/tmp/diff.patch and respond with:
- P0/P1 issues (bugs, security, correctness)
- Test gaps (TDD)
- Suggested improvements (small, actionable)
- If something is unclear, ask 1-3 precise questions." 
