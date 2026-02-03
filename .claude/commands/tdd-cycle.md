---
description: "TDD（Red→Green→Refactor）で実装するための実行手順を開始する"
argument-hint: "<対象機能/バグ>（省略可）"
allowed-tools: Bash(make test*), Bash(python3 scripts/ci/*), Read, Edit, Write
---

# /tdd-cycle — TDD を回す

## 手順（必須）
1. Red: 失敗するテストを追加（最小）
2. Green: テストが通る最小実装
3. Refactor: 重複除去・命名・設計改善（テスト維持）

## まずテストを走らせる（現状確認）
!bash scripts/ci/run_ci.sh --mode test-only || true

## 進め方
- 変更は小さく、1サイクルで 1つの意図
- 迷ったらタスクを更に分割して /exec-plan に戻す
