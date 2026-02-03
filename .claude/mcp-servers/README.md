# MCP Servers (local)

このディレクトリは、プロジェクト専用の MCP サーバ（stdio）を提供します。

## セットアップ

```bash
cd .claude/mcp-servers
npm install
```

## 提供サーバ

- `project-context`：プロジェクト構造／CI入口／依存の要約
- `worktree-manager`：git worktree の一覧・作成・削除（安全ガード付き）
- `ci-runner`：固定コマンドで CI を実行（任意）

MCP 設定は `.mcp.json`（Claude Code 参照）と `.claude/mcp.json`（人間用）にあります。
