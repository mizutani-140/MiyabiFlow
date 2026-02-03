---
name: exec-plan
description: "要件を[TDD前提のタスクDAG]に分解し、[並列開発]=git worktree の割当まで含む plan.json と TERMINAL_ASSIGNMENTS.md を生成する。"
argument-hint: "[要件/チケット/制約]（省略可）"
allowed-tools: Read, Write, Edit, Bash(git*), Bash(ls*), Bash(find*), Bash(cat*), Bash(python3 scripts/worktrees/*)
---

# [目的]
[AIコーディングエージェントA] が実装できる状態にするため、要件を「実行可能で小さい」タスクに分解し、worktree と担当を割り当てる。

このスキルは **コードを書き始める前** に必ず実行してよい。

# [入力]
- $ARGUMENTS（要件、チケットURL、制約、締切、優先度 など）
- 既存のリポジトリ状況（差分、CI、テスト基盤）

# [出力]
- `.ai/plans/[timestamp]_plan.json`
- `.ai/worktrees/TERMINAL_ASSIGNMENTS.md`

plan.json の構造は `references/plan_schema.json` を参照。

# [手順]
1. [コンテキスト収集]
   - 既存の `README`, `docs`, `CLAUDE.md`, `AGENTS.md` を読む
   - `git status`, `git diff --stat`, `git worktree list` を確認
   - CI エントリーポイント（`scripts/ci/run_ci.sh` / `make ci`）を確認

2. [抽象化]
   - 具体名を必要に応じて一般化ラベルで記述する
   - 例：
     - [AIコーディングエージェントA]=Claude Code
     - [AIコーディングエージェントB]=Codex
     - [生成タスク]=実装
     - [評価タスク]=レビュー・テスト

3. [タスク分解（TDD）]
   - まず Red を置く（失敗するテスト）
   - 次に Green（最小実装）
   - 最後に Refactor（設計改善）
   - 1タスクの粒度は「1回の集中で終わる」「失敗原因が1つに絞れる」程度に切る

4. [依存関係と並列化]
   - depends_on で DAG を作る
   - 並列可能なタスクは worktree を分ける
   - 統合作業（衝突解消、PR作成）はメイン端末に残す

5. [担当割当]
   - 原則：実装は [AIコーディングエージェントA]
   - レビュー/検証/テスト観点は [AIコーディングエージェントB]
   - [AIコーディングエージェントA] が同じ失敗を繰り返す場合は owner=hybrid または codex に寄せる

6. [成果物生成]
   - plan.json を `.ai/plans/` に保存
   - `TERMINAL_ASSIGNMENTS.md` を `.ai/worktrees/` に保存
   - 次に実行すべきコマンドを明記（例：/worktree-init plan.json）

# [完了条件]
- plan.json に DoD が入っている（テスト・CI・受け入れ条件）
- worktree がユニークで、作業手順が TERMINAL_ASSIGNMENTS.md に書かれている
- 不明点がある場合は「質問リスト」を plan.json の constraints/assumptions に残している
