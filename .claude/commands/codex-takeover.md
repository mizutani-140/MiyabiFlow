---
description: "Claude が詰まった時の引き継ぎ（handoff packet 作成→Codex へ依頼）"
argument-hint: "<現象/エラー要約>"
allowed-tools: Bash(bash scripts/codex/*), Bash(codex *), Bash(git diff*), Read, Write
---

# /codex-takeover — Codex 引き継ぎ

!bash scripts/codex/takeover.sh "$ARGUMENTS"
