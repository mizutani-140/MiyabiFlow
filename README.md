# AI Autonomous Dev System (Subscription-first)

Claude Code（サブスク）と Codex（サブスク）で、TDD と CI を前提に「AI自律駆動開発」を回すためのテンプレートです。

## 何が入っているか

- `.claude/`
  - `settings.json`（権限・フック・言語・forceLoginMethod）
  - `skills/`（計画、TDD、検証、レビュー、PR、MCP診断…）
  - `commands/`（/exec-plan 等の即実行コマンド）
  - `mcp.json` と `mcp-servers/`（Codex/ローカルMCP）
- `.mcp.json`（Claude Code が読む MCP 設定）
- `AGENTS.md`（Codex GitHub レビュー指示）
- `CLAUDE.md`（Claude Code 指示）
- GitHub Actions（CI、セキュリティ、AIレビュー）

## クイックスタート

1. Claude Code をログイン（Claude.ai）
2. Codex CLI をログイン（ChatGPT）
3. プロジェクトルートで `claude` を起動
4. `/exec-plan` → `/worktree-init <plan>` → 各 worktree で `/tdd-cycle` → `/exec-verify`
5. 仕上げに `/exec-review` → PR

詳細は `.claude/QUICK_START.md` を参照。

## CI 入口

- `bash scripts/ci/run_ci.sh --mode ci`
- `make ci`

プロジェクトに合わせて `scripts/ci/run_ci.sh` を調整してください。

## Codex GitHub レビュー

- PR コメントで `@codex review`
- ガイドラインは `AGENTS.md`

## 重要：サブスク優先

- Claude Code は `.claude/settings.json` の `forceLoginMethod=claudeai` により、基本的に Claude.ai ログインを強制します。


## MiyabiFlow（雅フロー）

- 初心者向けの運用手順: `docs/miyabiflow/README.md`
- 全体像: `docs/miyabiflow/00_MiyabiFlow_全体像.md`
