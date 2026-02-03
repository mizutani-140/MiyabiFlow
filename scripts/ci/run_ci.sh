#!/usr/bin/env bash
set -euo pipefail

MODE="ci"
if [[ "${1:-}" == "--mode" ]]; then
  MODE="${2:-ci}"
  shift 2
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

CONFIG_FILE=".ai/config/ci.json"

log() { printf "%s\n" "$*" >&2; }
run() { log "+ $*"; "$@"; }

# Load optional config (json) for repo-specific commands
CI_LINT=()
CI_TEST=()
CI_TYPECHECK=()

if [[ -f "$CONFIG_FILE" ]]; then
  python3 - <<'PY' "$CONFIG_FILE"
import json,sys
p=sys.argv[1]
cfg=json.load(open(p,'r',encoding='utf-8'))
for k in ("lint","test","typecheck"):
    arr=cfg.get(k,[])
    if not isinstance(arr,list):
        arr=[]
    print(k+"="+("||".join(arr)))
PY
  | while IFS= read -r line; do
      key="${line%%=*}"
      val="${line#*=}"
      IFS='||' read -r -a arr <<<"$val"
      case "$key" in
        lint) CI_LINT=("${arr[@]}");;
        test) CI_TEST=("${arr[@]}");;
        typecheck) CI_TYPECHECK=("${arr[@]}");;
      esac
    done
fi

has_cmd() { command -v "$1" >/dev/null 2>&1; }
has_make_target() {
  [[ -f Makefile ]] || return 1
  grep -qE "^$1:" Makefile
}

# Auto-detect fallback commands if config is empty
detect_defaults() {
  # Node
  if [[ -f package.json ]] && has_cmd npm; then
    # Determine if scripts exist
    if python3 - <<'PY' >/dev/null 2>&1; then
import json
p=json.load(open("package.json","r",encoding="utf-8"))
s=p.get("scripts",{})
print("lint" in s)
PY
    then :; fi
  fi
}

# Prefer Makefile targets if present (repo-defined)
if has_make_target ci; then
  log "[CI] Using Makefile target: ci"
  run make ci
  exit 0
fi

# If repo provides config commands, run them
run_cmd_list() {
  local label="$1"; shift
  local -a cmds=("$@")
  if [[ "${#cmds[@]}" -eq 0 ]]; then
    return 0
  fi
  log "[CI] $label"
  for c in "${cmds[@]}"; do
    [[ -z "$c" ]] && continue
    # shellcheck disable=SC2086
    run bash -lc "$c"
  done
}

# Auto-detect simple defaults if config missing
if [[ "${#CI_LINT[@]}" -eq 0 && "${#CI_TEST[@]}" -eq 0 && "${#CI_TYPECHECK[@]}" -eq 0 ]]; then
  # Heuristics:
  if [[ -f package.json ]] && has_cmd npm; then
    CI_LINT=("npm run lint --if-present")
    CI_TEST=("npm test --silent --if-present")
    CI_TYPECHECK=("npm run typecheck --if-present")
  elif [[ -f pyproject.toml ]] || [[ -f requirements.txt ]]; then
    if has_cmd pytest; then CI_TEST=("pytest"); fi
    if has_cmd ruff; then CI_LINT=("ruff check ."); fi
    if has_cmd mypy; then CI_TYPECHECK=("mypy ."); fi
  fi
fi

case "$MODE" in
  test-only)
    run_cmd_list "Test" "${CI_TEST[@]}"
    ;;
  ci|*)
    run_cmd_list "Lint" "${CI_LINT[@]}"
    run_cmd_list "Typecheck" "${CI_TYPECHECK[@]}"
    run_cmd_list "Test" "${CI_TEST[@]}"
    ;;
esac

log "[CI] Done"
