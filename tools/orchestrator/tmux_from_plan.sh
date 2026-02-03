#!/usr/bin/env bash
set -euo pipefail

# Create [ターミナル多重化層] (tmux) windows from a plan JSON.
# Each task becomes a tmux window; each window has 2 panes:
#   left: [AIコーディングエージェントA] (Claude Code)
#  right: [AIコーディングエージェントB] (Codex)
#
# Usage:
#   ./tools/orchestrator/tmux_from_plan.sh .ai/plans/<plan>.json [session]
#
# Notes:
# - This does NOT auto-run claude/codex (to avoid surprise prompts). It only prints suggested commands.
# - It will create missing worktrees using worktree_create.sh.

PLAN_PATH="${1:-}"
SESSION_NAME="${2:-ai-dev-plan}"

if [[ -z "$PLAN_PATH" ]]; then
  echo "Usage: $0 <plan.json> [session]" >&2
  exit 2
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found. Install tmux or open terminals manually." >&2
  exit 1
fi

if [[ ! -f "$PLAN_PATH" ]]; then
  echo "Plan not found: $PLAN_PATH" >&2
  exit 1
fi

# Extract tasks as TSV: id,agent,worktree,title
TASKS_TSV="$(python3 - <<'PY'
import json,sys
path=sys.argv[1]
p=json.load(open(path,'r',encoding='utf-8'))
for t in p.get('tasks',[]):
  tid=t.get('id','')
  agent=t.get('agent','')
  wt=t.get('worktree','')
  title=t.get('title','').replace('\t',' ').replace('\n',' ')
  print(f"{tid}\t{agent}\t{wt}\t{title}")
PY
"$PLAN_PATH")"

# Create session if missing
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  tmux new-session -d -s "$SESSION_NAME" -n "T0-main"
  tmux send-keys -t "$SESSION_NAME":0 "echo '[T0] Run: ./tools/bootstrap/subscription_guard.sh'" C-m
fi

# For each task, create window with 2 panes and helpful commands
i=1
while IFS=$'\t' read -r tid agent wt title; do
  [[ -z "$tid" ]] && continue
  win="${tid}-${agent}"

  # Create worktree if set and missing
  if [[ -n "$wt" ]]; then
    ./tools/orchestrator/worktree_create.sh "$wt" >/dev/null 2>&1 || true
  fi

  tmux new-window -t "$SESSION_NAME" -n "$win"
  tmux split-window -h -t "$SESSION_NAME":"$win"

  # Titles
  tmux select-pane -t "$SESSION_NAME":"$win".0 -T "A:Claude"
  tmux select-pane -t "$SESSION_NAME":"$win".1 -T "B:Codex"

  # Left pane: cd worktree (if any) and show instructions
  if [[ -n "$wt" ]]; then
    tmux send-keys -t "$SESSION_NAME":"$win".0 "cd .worktrees/$wt" C-m
  fi
  tmux send-keys -t "$SESSION_NAME":"$win".0 "echo '[${tid}] ${title}'" C-m
  tmux send-keys -t "$SESSION_NAME":"$win".0 "echo 'Run: claude (use /agents to pick subagent if needed)'" C-m

  # Right pane: codex instructions
  if [[ -n "$wt" ]]; then
    tmux send-keys -t "$SESSION_NAME":"$win".1 "cd .worktrees/$wt" C-m
  fi
  tmux send-keys -t "$SESSION_NAME":"$win".1 "echo '[${tid}] ${title}'" C-m
  tmux send-keys -t "$SESSION_NAME":"$win".1 "echo 'Run: codex (review/test) or rely on @codex in PR'" C-m

  i=$((i+1))
done <<< "$TASKS_TSV"

tmux select-window -t "$SESSION_NAME":0
tmux attach -t "$SESSION_NAME"
