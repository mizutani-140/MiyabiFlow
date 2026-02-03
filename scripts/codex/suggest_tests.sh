#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

mkdir -p .ai/tmp
git diff > .ai/tmp/diff.patch || true

codex exec "You are [AIコーディングエージェントB]. We are doing TDD.

Task scope: ${TARGET:-unspecified}

1) Read AGENTS.md test guidelines.
2) Inspect current repository structure.
3) Propose concrete tests to add (file names + test cases).
4) If possible, provide code snippets for the tests, but keep them minimal.
5) Note any missing seams/mocks that make testing hard and suggest refactors." 
