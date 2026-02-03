---
description: "Codex CLI にローカル差分レビューを依頼する（ChatGPTログイン前提）"
argument-hint: "<フォーカス>（例: security / perf / tests）"
allowed-tools: Bash(bash scripts/codex/*), Bash(codex *), Bash(git diff*), Read
---

# /codex-review — Codex にレビューさせる

!bash scripts/codex/review_diff.sh "$ARGUMENTS"
