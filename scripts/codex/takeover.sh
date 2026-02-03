#!/usr/bin/env bash
set -euo pipefail

SYMPTOM="${1:-unspecified}"

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

mkdir -p .ai/handoff .ai/tmp

TS="$(date -u +%Y%m%dT%H%M%SZ)"
PACKET=".ai/handoff/${TS}_handoff.md"

# Capture useful context
git status --porcelain > .ai/tmp/git_status.txt || true
git diff > .ai/tmp/diff.patch || true

# Try to capture latest CI report if present
LATEST_REPORT="$(ls -1t .ai/reports 2>/dev/null | head -n 1 || true)"
REPORT_PATH=""
if [[ -n "$LATEST_REPORT" ]]; then
  REPORT_PATH=".ai/reports/${LATEST_REPORT}"
fi

cat > "$PACKET" <<EOF
# Handoff Packet (${TS})

## Symptom
${SYMPTOM}

## Goal
Fix the problem with minimal, safe changes. Keep TDD. Keep CI green.

## Repository notes
- Follow AGENTS.md review/test guidelines.
- Diff: .ai/tmp/diff.patch

## Current status
\`\`\`
$(cat .ai/tmp/git_status.txt 2>/dev/null || true)
\`\`\`

## If CI report exists
${REPORT_PATH}

## Request
1) Identify the root cause (based on diff + repo inspection).
2) Propose a fix plan.
3) Provide a patch (or explicit file edits).
4) Specify how to verify (commands).
EOF

echo "[handoff] wrote $PACKET" >&2

codex exec "You are [AIコーディングエージェントB]. Claude Code got stuck.

Read the handoff packet at: ${PACKET}

Deliver:
- Root cause analysis
- Minimal patch
- Verification commands
- Any follow-up recommendations." 
