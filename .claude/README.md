# MiyabiFlow（雅フロー）対応 AI自律駆動開発プラグイン（Claude Code × Codex × git worktree）

このリポジトリは、単一のローカル端末／複数の worktree 端末で **Claude Code が実装**し、**Codex がレビュー／検証／テスト**を担う「AI自律駆動開発」を本番運用レベルで回すための共有設定（`.claude/`・`.mcp.json`・CI）を提供します。

## 目的

- [AIコーディングエージェントA]=Claude Code が **[生成タスク]**（実装・修正）を担当
- [AIコーディングエージェントB]=Codex が **[評価タスク]**（レビュー・テスト・検証）を担当
- [並列開発]=`git worktree` で複数タスクを同時進行
- [CI/CD]=GitHub Actions で自動テスト・自動レビュー（コメント駆動）を実行
- [TDD]=Red→Green→Refactor を最優先に、AIが暴走しない開発に寄せる

## ディレクトリ概要

- `.claude/`
  - `settings.json`：権限・フック・言語設定（チーム共有）
  - `agents/`：役割別サブエージェント（並列開発・品質ゲート）
  - `skills/`：自律駆動の中核スキル（計画→分割→実装→検証→レビュー→PR）
  - `commands/`：すぐ呼べる運用コマンド（/exec-verify 等）
  - `mcp.json` / `mcp-servers/`：MCP連携（Codex・プロジェクト要約・worktree管理）
  - `hooks/`：危険コマンド遮断／LDDログ／Stop品質ゲート
- `.mcp.json`：Claude Code のプロジェクト MCP 設定（Claude Code が参照）
- `AGENTS.md`：Codex GitHub レビュー指示（Codex は AGENTS.md を読む）
- `CLAUDE.md`：Claude Code のプロジェクト指示（Claude は CLAUDE.md を読む）
- `.github/workflows/`：CI と AIレビューの自動化

## まず読む

- `.claude/QUICK_START.md`
- `.claude/TROUBLESHOOTING.md`
- `docs/parallel-worktrees.md`


## MiyabiFlow（雅フロー）入口

- `/miyabiflow`：初心者でも回せる“提案＋Plan＋worktree割当＋コピペパック生成”
- ドキュメント: `docs/miyabiflow/`
