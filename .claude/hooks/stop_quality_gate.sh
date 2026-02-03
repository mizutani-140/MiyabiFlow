#!/usr/bin/env bash
set -euo pipefail

# Stop hook (Claude Code):
# - Enforces a lightweight quality gate before Claude "stops"
# - Prefers ./scripts/ci/run_ci.sh, falls back to `make ci`
# - If no CI entrypoint exists, exits 0 (no-op)

INPUT="$(cat || true)"

# Avoid infinite loops: if Claude already re-entered due to Stop hook, do nothing.
# (Best-effort: payload may include stop_hook_active depending on version.)
STOP_ACTIVE="$(python3 - <<'PY' <<<"$INPUT" 2>/dev/null || echo "false"
import json,sys
s=sys.stdin.read().strip()
try:
    j=json.loads(s) if s else {}
except Exception:
    j={}
print("true" if j.get("stop_hook_active") else "false")
PY
)"
if [[ "$STOP_ACTIVE" == "true" ]]; then
  exit 0
fi

# Only run inside git repos
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

STATE_FILE=".ai/state/state.json"
mkdir -p "$(dirname "$STATE_FILE")"

# Determine whether we have a CI entrypoint
CI_CMD=""
if [[ -x "./scripts/ci/run_ci.sh" ]]; then
  CI_CMD="./scripts/ci/run_ci.sh"
elif [[ -f "./scripts/ci/run_ci.sh" ]]; then
  CI_CMD="bash ./scripts/ci/run_ci.sh"
elif [[ -f "Makefile" ]] && grep -qE '^ci:' Makefile; then
  CI_CMD="make ci"
else
  # Nothing to run
  exit 0
fi

LAST_SHA=""
if [[ -f "$STATE_FILE" ]]; then
  LAST_SHA="$(python3 -c 'import json,sys; 
p=json.load(open(sys.argv[1], "r", encoding="utf-8")); 
print(p.get("quality_gate",{}).get("last_checked","") or "")' "$STATE_FILE" 2>/dev/null || true)"
fi

CURRENT_SHA="$(git rev-parse HEAD 2>/dev/null || echo "")"
DIRTY="$(git status --porcelain 2>/dev/null | wc -l | tr -d " ")"

# If clean and checked on this sha already, skip
if [[ "$DIRTY" == "0" ]] && [[ -n "$CURRENT_SHA" ]] && [[ "$LAST_SHA" == "$CURRENT_SHA" ]]; then
  exit 0
fi

echo "[品質ゲート] Running: $CI_CMD" >&2
set +e
eval "$CI_CMD"
RC=$?
set -e

python3 - <<'PY' "$STATE_FILE" "$CURRENT_SHA" "$RC"
import json,sys,os,datetime
path=sys.argv[1]; sha=sys.argv[2]; rc=int(sys.argv[3])
try:
    data=json.load(open(path,"r",encoding="utf-8"))
except Exception:
    data={}
data.setdefault("quality_gate", {})
data["quality_gate"]["last_checked"]=sha
data["quality_gate"]["last_checked_at"]=datetime.datetime.utcnow().isoformat()+"Z"
data["quality_gate"]["last_checked_rc"]=rc
if rc==0:
    data["quality_gate"]["last_passed_git_sha"]=sha
    data["quality_gate"]["last_passed_at"]=datetime.datetime.utcnow().isoformat()+"Z"
os.makedirs(os.path.dirname(path), exist_ok=True)
json.dump(data, open(path,"w",encoding="utf-8"), ensure_ascii=False, indent=2)
open(path,"a",encoding="utf-8").write("\n")
PY

if [[ "$RC" -eq 0 ]]; then
  exit 0
fi

echo "[品質ゲート] FAILED: CI is red. Claude must continue fixing issues." >&2
echo "Hint: run the same command locally, fix failures, then try again." >&2
exit 2
