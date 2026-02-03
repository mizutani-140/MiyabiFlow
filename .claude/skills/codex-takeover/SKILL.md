---
name: codex-takeover
description: "Claude Code が詰まったときに、失敗ログ・再現手順・diff をまとめて Codex に引き継ぐ。"
argument-hint: "[現象/エラー要約]"
allowed-tools: Bash(bash scripts/codex/*), Bash(codex *), Bash(git diff*), Bash(git status*), Read, Write
---

# [目的]
[AIコーディングエージェントA] が同一障害で停滞した場合に、[AIコーディングエージェントB] へ安全に引き継ぐ。

# [手順]
1. 現象を $ARGUMENTS に要約（1〜2文）
2. `scripts/codex/takeover.sh` で handoff packet を作成
3. Codex に以下を要求
   - 根本原因
   - 最小パッチ
   - 検証コマンド
4. 提案パッチを取り込み、/exec-verify を通す

# [完了条件]
- handoff packet が `.ai/handoff/` に残っている
- CI が緑になった
- 修正理由が PR 本文に反映された
