# TROUBLESHOOTING

## Claude Code が API 課金（Claude Console）側でログインされてしまう
`.claude/settings.json` の `forceLoginMethod` を `claudeai` に固定しています。
それでも切り替わる場合は、`claude` を再ログインしてください。

## codex がログインできない／ブラウザが開けない
- `codex login --device-auth` を試してください（ヘッドレス向け）
- `~/.codex/auth.json` の取り扱いに注意（トークンが含まれる）

## MCP サーバが起動しない
- `.mcp.json` の server を一度無効化して切り分け
- `.claude/mcp-servers/README.md` の手順で `npm install` を実行
- `/mcp`（Claude Code 組み込み）でサーバ一覧とエラーを確認

## Stop 品質ゲートで止まる（CIが無いのに `make ci` を要求される）
`stop_quality_gate.sh` は以下優先で探します：
1) `./scripts/ci/run_ci.sh`
2) `Makefile` の `ci:` ターゲット

どちらも無い場合は no-op になります。もし止まる場合はファイル権限やパスを確認してください。

## Claude Code が同じエラーを連発して進まない
`/.codex-takeover` を実行して [AIコーディングエージェントB] に引き継ぎます。
- 失敗ログ
- 再現手順
- 期待結果
- 現状の diff
をまとめて Codex に渡し、パッチ案を生成させます。
