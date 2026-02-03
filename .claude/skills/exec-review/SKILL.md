---
name: exec-review
description: "差分レビューを行い、P0/P1（バグ・セキュリティ・テスト欠落）を潰してから PR へ進む。必要なら Codex に二重レビューを依頼する。"
argument-hint: "[フォーカス: security|perf|tests|api]（省略可）"
allowed-tools: Bash(git diff*), Bash(git status*), Read, Edit, Write, Bash(bash scripts/codex/*), Bash(codex *)
---

# [目的]
AI 実装の品質を担保するため、レビューを「工程」として固定化する。

# [レビュー手順]
1. 差分を要約（変更点の意図、影響範囲、互換性）
2. P0/P1 を先に潰す
   - P0: 重大バグ、セキュリティ、データ破壊、ビルド不可
   - P1: 回帰しやすい、テスト不足、性能劣化、保守性低下
3. テスト観点（境界、異常系、回帰）
4. API/UX 互換性（破壊的変更の有無）
5. 必要に応じて Codex に二重レビュー（/codex-review）

# [出力]
- レビュー結果を箇条書きで残す（P0/P1 を明示）
- 修正が必要なら「修正タスク」として切り出す（/exec-plan に戻ってもよい）

# [完了条件]
- P0 が 0 件
- P1 が妥当な理由付きで解消/受容されている
- CI が緑
