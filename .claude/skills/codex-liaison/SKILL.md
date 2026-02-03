---
name: codex-liaison
description: "Codex を[評価タスク]（レビュー/テスト/検証）に組み込み、Claude Code が詰まった場合の補助・代替実装までの判断基準を提供する。"
argument-hint: "[目的: review|tests|verify|implement] [補足]（省略可）"
allowed-tools: Bash(codex *), Bash(bash scripts/codex/*), Read, Write, Edit
---

# [目的]
[AIコーディングエージェントA] と [AIコーディングエージェントB] を「衝突しない役割分担」で運用する。

# [基本方針]
- [AIコーディングエージェントA]：実装（生成タスク）
- [AIコーディングエージェントB]：評価（レビュー・テスト・検証）

# [いつ Codex を呼ぶか]
- レビュー観点が不足していると感じたとき
- テスト設計が難しいとき（境界・異常系）
- CI が不安定／環境依存で原因が追えないとき
- Claude が同じ失敗を繰り返すとき（2回目で切替）

# [Codex に渡す情報（最低限）]
- ゴール（何を満たせば完了か）
- 現状（diff / エラーログ / 再現手順）
- 制約（互換性、性能、セキュリティ、期限）
- 期待する出力形式（パッチ/箇条書き/手順）

# [運用レシピ]
- レビュー：/codex-review
- テスト提案：/codex-test
- 停滞時：/codex-takeover

# [完了条件]
- Codex の指摘がトリアージされ、P0/P1 が解消されている
