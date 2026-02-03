---
name: mcp-doctor
description: "MCP（Model Context Protocol）連携が壊れたときに診断・復旧する。Codex MCP サーバやローカル MCP サーバのセットアップも含む。"
allowed-tools: Bash(bash .claude/mcp-servers/*), Bash(node .claude/mcp-servers/*), Read, Write, Edit
---

# [目的]
MCP サーバが起動しない／ツールが見えない／認証が切れた、などを迅速に切り分ける。

# [チェック手順]
1. `.mcp.json` の server 定義を確認（disabled、command、args）
2. `node` と `.claude/mcp-servers` の依存が入っているか確認
   - `cd .claude/mcp-servers && npm install`
3. Codex の認証を確認（`codex login` / `codex whoami` 相当）
4. Claude Code 側で `/mcp` を開き、サーバのエラーを確認

# [復旧]
- 依存が無ければインストール
- server を一旦 disabled にして最小構成に戻し、段階的に有効化

# [完了条件]
- `/mcp` に期待するサーバが表示される
- codex / project-context / worktree-manager が利用可能
