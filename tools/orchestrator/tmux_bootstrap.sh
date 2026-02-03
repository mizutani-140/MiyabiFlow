#!/usr/bin/env bash
set -euo pipefail

# Bootstraps a tmux session for parallel AI development.
# Layout:
#   - Pane 0: [AIコーディングエージェントA] (Claude Code) coordinator
#   - Pane 1: worktree implementer
#   - Pane 2: [AIコーディングエージェントB] (Codex) reviewer/tester

SESSION_NAME="${1:-ai-dev}"

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found. Install tmux or open 3 terminals manually." >&2
  echo "Suggested roles:" >&2
  echo "  T1: claude (coordinator / implementer)" >&2
  echo "  T2: claude (worktree implementer)" >&2
  echo "  T3: codex (review/test)" >&2
  exit 1
fi

tmux has-session -t "$SESSION_NAME" 2>/dev/null && {
  echo "Session already exists: $SESSION_NAME" >&2
  tmux attach -t "$SESSION_NAME"
  exit 0
}

tmux new-session -d -s "$SESSION_NAME" -n main

# Split into 3 panes
tmux split-window -h -t "$SESSION_NAME":0
tmux split-window -v -t "$SESSION_NAME":0.1

# Titles
tmux select-pane -t "$SESSION_NAME":0.0 -T "A:Claude(Coordinator)"
tmux select-pane -t "$SESSION_NAME":0.1 -T "A:Claude(Implementer)"
tmux select-pane -t "$SESSION_NAME":0.2 -T "B:Codex(Review/Test)"

# Helpful commands (not auto-running)
tmux send-keys -t "$SESSION_NAME":0.0 "echo '[Pane A0] Run: claude --agent coordinator' " C-m
tmux send-keys -t "$SESSION_NAME":0.1 "echo '[Pane A1] cd into a worktree under .worktrees/<task> then run: claude' " C-m
tmux send-keys -t "$SESSION_NAME":0.2 "echo '[Pane B] Run: codex --help (or codex exec ...)'" C-m

tmux select-pane -t "$SESSION_NAME":0.0
tmux attach -t "$SESSION_NAME"
