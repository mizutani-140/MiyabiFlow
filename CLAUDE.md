# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Claude Code（AIコーディングエージェントA）と Codex（AIコーディングエージェントB）を組み合わせて、TDD と CI を前提に AI 自律駆動開発を行うためのテンプレートリポジトリ。

- **Claude Code**: 生成タスク（実装・修正）を担当
- **Codex**: 評価タスク（レビュー・テスト・検証）を担当
- **git worktree**: 複数タスクの並列開発に使用

## ビルド・テスト・CI コマンド

```bash
# CI 全体（lint → typecheck → test）
make ci
# または
bash scripts/ci/run_ci.sh --mode ci

# テストのみ
make test
# または
bash scripts/ci/run_ci.sh --mode test-only

# セキュリティスキャン
make security
# または
bash scripts/security/scan.sh
```

CI コマンドの内容はプロジェクトごとに `.ai/config/ci.json` で定義可能。未定義の場合は `package.json` や `pyproject.toml` から自動検出される。

## 基本ルール

- 変更は小さく、意図を説明できる差分にする
- TDD（Red→Green→Refactor）を優先
- CI 相当コマンドが通るまで完了扱いにしない
- `git push`, `gh pr create`, `worktree remove` などの破壊的操作は必ずユーザー確認を行う

## 推奨フロー（並列開発）

1. `/exec-plan` でタスク分解と worktree 割当を生成
2. `/worktree-init <plan>` で worktree を作成
3. 各 worktree 端末で `/tdd-cycle` → 実装 → `/exec-verify`
4. 統合後に `/exec-review`
5. `/pr-open`（任意）で PR 作成

初心者向け最短フロー: `/miyabiflow <やりたいこと>` を実行すると、提案→Plan→worktree割当→コピペパック生成までガイドされる。

## Codex 連携（評価タスク）

- `/codex-review`: 差分レビュー（P0/P1）
- `/codex-test`: テスト観点の提案
- `/codex-takeover`: 詰まった時の引き継ぎ（handoff packet）

GitHub PR でのレビュー:
- PR コメントで `@codex review`
- レビュー基準は `AGENTS.md` を参照

## アーキテクチャ

```
.claude/
├── settings.json     # 権限・フック・言語設定（forceLoginMethod=claudeai）
├── agents/           # 21体のサブエージェント（coordinator, planner, tdd-red 等）
├── skills/           # 自律駆動スキル（exec-plan, tdd-cycle, exec-verify 等）
├── commands/         # 即実行コマンド
├── hooks/            # 危険コマンド遮断・LDDログ・品質ゲート
└── mcp.json          # MCP サーバ設定
.mcp.json             # Claude Code が読む MCP 設定
AGENTS.md             # Codex GitHub レビュー指示
scripts/
├── ci/run_ci.sh      # CI 統一入口
├── security/scan.sh  # セキュリティスキャン
├── codex/            # Codex 連携スクリプト
└── worktrees/        # worktree 管理スクリプト
.ai/
├── config/ci.json    # プロジェクト固有の CI コマンド定義
├── plans/            # 生成された計画
├── worktrees/        # worktree 割当情報
└── state/            # 状態管理
```

## worktree 運用

- worktree は `.worktrees/` 配下に作成（git 管理しない）
- 1 worktree = 1 責務（小さく保つ）
- 片付け: `python3 scripts/worktrees/cleanup_worktrees.py --yes && git worktree prune`

## MCP

- `.mcp.json` に MCP サーバ定義
- `/mcp-doctor` で診断可能

## MiyabiFlow（雅フロー）前提

- ユーザーは初心者で、**差分レビューを理解できない**前提
- ユーザーは**ターミナルにコマンドを打たない**。Claude Code が実行し、ユーザーは「許可クリック」だけ
- 承認を求めるのは重要なものだけ（技術スタック変更、権限/コスト増、本番デプロイ/データ移行）

詳細: `docs/miyabiflow/README.md`
