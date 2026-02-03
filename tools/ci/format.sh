#!/usr/bin/env bash
set -euo pipefail

# Placeholder formatter entrypoint.
# Customize per-language (black, ruff, prettier, gofmt, rustfmt, etc.)

if [[ -f package.json ]]; then
  if npm run -s format >/dev/null 2>&1; then
    npm run -s format
    exit 0
  fi
fi

echo "No formatter configured. Implement in tools/ci/format.sh" >&2
exit 0
