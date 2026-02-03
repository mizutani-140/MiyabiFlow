---
name: tdd-cycle
description: "TDD（Red→Green→Refactor）で変更を安全に積み上げるための進め方とチェックリストを提供する。"
argument-hint: "[対象機能/バグ]"
allowed-tools: Read, Edit, Write, Bash(bash scripts/ci/*), Bash(make test*)
---

# [目的]
AI が大きく変更して破綻しないよう、テスト駆動で小さく進める。

# [手順]
## 1) Red（失敗するテスト）
- 追加するテストは 1つの意図に絞る
- 失敗メッセージが「次に何を直すべきか」を示すように書く

## 2) Green（最小実装）
- 最小の実装でテストを通す
- 余計な最適化をしない

## 3) Refactor（設計改善）
- 重複排除、責務分割、命名改善
- テストは必ず緑を維持

# [ガードレール]
- テストが書けない場合：
  - I/O 境界を切る
  - 依存を注入できる設計にする
  - 小さい純粋関数へ寄せる
- 変更が大きくなる兆候：
  - タスクを /exec-plan で再分割する

# [完了条件]
- 追加したテストが意図を説明している
- `scripts/ci/run_ci.sh --mode test-only` が成功する
