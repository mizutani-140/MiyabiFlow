# [AIコーディングエージェントA] → [AIコーディングエージェントB] 連携（MCP）

このプロジェクトは `.mcp.json` に `codex mcp-server` を定義しており、
[AIコーディングエージェントA]（Claude Code）から [AIコーディングエージェントB]（Codex）を
**MCPツールとして呼び出す**構成を想定します。

---

## 前提（Subscription-first）
- ローカルに `codex` CLI が入っている
- Codex CLI が **ChatGPT サインイン**で利用可能（= [定額サブスクリプション認証]）
- `OPENAI_API_KEY` は **未設定**であること（従量課金に寄せたくない場合）

---

## 使い方（概念）
1) Claude Code で `/mcp` を確認し、`codex` サーバが有効なことを確認  
2) Claude から MCP tool `codex` を呼び出してレビュー/検証させる  
   - sandbox: read-only（推奨）
   - cwd: 作業中worktree（推奨）

---

## 注意
- まずは “レビュー専用” で使うのが安全（workspace-write は段階導入）
- ルールは `CLAUDE.md` / `AGENTS.md` に従う
- どうしても CI で Codex を Actions から実行したい場合は、別途 [従量課金API認証] が必要になることがあります
