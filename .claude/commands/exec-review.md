---
description: "差分レビュー（設計・テスト・セキュリティ）を行い、必要なら Codex レビューも実行する"
argument-hint: "<フォーカス>（例: security / perf / tests）"
allowed-tools: Bash(git*), Bash(bash scripts/codex/*), Read, Edit, Write
---

# /exec-review — [評価タスク]（レビュー）

## 差分サマリ
!git diff --stat
!git diff

## チェックリスト（P0/P1中心）
- 正しさ：仕様と一致、境界条件
- テスト：TDDの意図が残っている（回帰防止）
- セキュリティ：秘密情報、入力検証、認可
- 互換性：既存API破壊、マイグレーション
- 可読性：命名、責務分離

## Codex でもう一回見る（任意）
（必要なら）次を実行：/codex-review $ARGUMENTS
