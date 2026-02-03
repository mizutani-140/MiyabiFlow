---
name: exec-verify
description: "CI 相当コマンドを実行し、失敗を要約して修正ループを回す。詰まった場合は Codex へフェイルオーバーする。"
allowed-tools: Bash(bash scripts/ci/*), Bash(make ci*), Read, Edit, Write, Bash(bash scripts/codex/*), Bash(codex *)
---

# [目的]
[評価タスク]（テスト・リンタ・型・フォーマット）を必ず通し、CI が赤い状態で止まらない。

# [基本フロー]
1. `scripts/ci/run_ci.sh --mode ci` を実行
2. 失敗の原因を 1つに絞る（最初のエラーが本体）
3. 最小修正 → 再実行
4. 2回同じ場所で詰まったら /codex-takeover（または codex-liaison）へ切り替える

# [出力]
- 修正ループの状況を `.ai/logs/` に残す（hooks が自動で記録）

# [フェイルオーバー条件]
- 同一エラーで 2回以上停滞
- 依存関係や環境差で原因が不明
- 大きなリファクタが必要で手順が迷子

その場合：
- `.ai/handoff/*` を作って Codex に渡す（/codex-takeover）

# [完了条件]
- `scripts/ci/run_ci.sh --mode ci` が成功
- 追加したテストが意図を説明
