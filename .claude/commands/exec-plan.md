---
description: "要件から[タスク分解]→[worktree割当]→実行手順を生成し、.ai/plans/ と .ai/worktrees/ に保存する"
argument-hint: "<要件/チケット/PRリンク>（省略可）"
allowed-tools: Bash(git*), Bash(ls*), Bash(find*), Bash(cat*), Read, Write, Edit
---

# /exec-plan — [計画]と[並列実行マップ]を作る

## 収集（現在の状態を把握）
!git status --porcelain
!git branch --show-current
!git worktree list
!ls

## 目的
- [AIコーディングエージェントA] が実装できるように、要件を **実行可能な最小タスク**に分割する
- `git worktree` 前提で、タスクごとに **作業ディレクトリ（worktree）** と **担当エージェント** を割り当てる
- 生成物：
  - `.ai/plans/<timestamp>_plan.json`
  - `.ai/worktrees/TERMINAL_ASSIGNMENTS.md`

## ルール（必須）
- タスクは **TDD** を前提に「Red→Green→Refactor」の順に分解する
- 各タスクは「完了条件（DoD）」を持つ（テスト・受け入れ条件・CI）
- 依存関係（DAG）を明示し、並列可能なものを抽出する
- コンテキストは抽象化ラベルを使う：
  - [AIコーディングエージェントA] / [AIコーディングエージェントB] / [コマンドライン実行環境]
  - [生成タスク] / [評価タスク] / [成果物]

## 出力フォーマット（plan.json）
- `plan_id` / `created_at` / `goal`
- `tasks[]`：
  - `id`（例: TASK-001）
  - `title`
  - `type`（tdd-red|tdd-green|refactor|docs|ci|security）
  - `depends_on[]`
  - `worktree`（例: wt/task-001）
  - `owner`（claude|codex|hybrid）
  - `acceptance`（配列でOK）
  - `commands`（実行コマンド候補。CIコマンドも含む）

## 次のアクション
1. plan.json と TERMINAL_ASSIGNMENTS.md を作成
2. その後、ユーザーに「/worktree-init <plan>」を案内する
