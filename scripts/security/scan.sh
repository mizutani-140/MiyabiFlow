#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

echo "[security] scanning for obvious secret patterns..."
# Basic grep (non-exhaustive)
git grep -nE "(AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH) PRIVATE KEY|SECRET_KEY=|API_KEY=|PRIVATE_KEY=|PASSWORD=|TOKEN=)" -- . || true

echo "[security] scanning for accidental .env commits..."
if git ls-files | grep -E '(^|/)\.env(\.|$)' >/dev/null 2>&1; then
  echo "[security] WARNING: .env file tracked by git" >&2
  git ls-files | grep -E '(^|/)\.env(\.|$)' >&2
  exit 1
fi

echo "[security] done"
