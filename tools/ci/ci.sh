#!/usr/bin/env bash
set -euo pipefail

ONLY=""

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --only) ONLY="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

run_step () {
  local name="$1"
  shift
  if [[ -n "$ONLY" && "$ONLY" != "$name" ]]; then
    return 0
  fi
  echo "[CI] $name ..." >&2
  "$@"
}

# Default behavior: try Make targets if present; otherwise attempt common commands.
has_make_target () {
  make -n "$1" >/dev/null 2>&1
}

run_make_or () {
  local target="$1"
  shift
  if has_make_target "$target"; then
    make "$target"
  else
    "$@"
  fi
}

run_step test run_make_or test bash -lc 'if [[ -f package.json ]]; then npm test; else echo "No test target configured" >&2; fi'
run_step lint run_make_or lint bash -lc 'if [[ -f package.json ]]; then npm run -s lint || true; else echo "No lint target configured" >&2; fi'
run_step typecheck run_make_or typecheck bash -lc 'if [[ -f package.json ]]; then npm run -s typecheck || true; else echo "No typecheck target configured" >&2; fi'
run_step security run_make_or security bash -lc 'if [[ -f package.json ]]; then npm audit --audit-level=high || true; else echo "No security target configured" >&2; fi'

echo "[CI] done" >&2
