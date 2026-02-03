#!/usr/bin/env bash
set -euo pipefail

# [定額サブスクリプション認証] を前提に、誤って [従量課金API認証] に切り替わるのを防ぐガード。
# - Claude Code: ANTHROPIC_API_KEY があると API キー経路に切り替わる可能性がある
# - Codex: OPENAI_API_KEY があると API キー経路に切り替わる可能性がある

fail=0

if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "❌ ANTHROPIC_API_KEY が設定されています。ローカルが [従量課金API認証] になる可能性があります。" >&2
  echo "   -> サブスク運用にするなら unset ANTHROPIC_API_KEY" >&2
  fail=1
else
  echo "✅ ANTHROPIC_API_KEY は未設定（サブスク運用向け）"
fi

if [[ -n "${OPENAI_API_KEY:-}" ]]; then
  echo "❌ OPENAI_API_KEY が設定されています。ローカルが [従量課金API認証] になる可能性があります。" >&2
  echo "   -> サブスク運用にするなら unset OPENAI_API_KEY" >&2
  fail=1
else
  echo "✅ OPENAI_API_KEY は未設定（サブスク運用向け）"
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "⚠️  claude コマンドが見つかりません。Claude Code をインストールしてください。" >&2
else
  echo "✅ claude found: $(command -v claude)"
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "⚠️  codex コマンドが見つかりません。Codex CLI をインストールしてください。" >&2
else
  echo "✅ codex found: $(command -v codex)"
fi

echo ""
echo "ヒント（Codex サブスク強制）:"
echo "  ~/.codex/config.toml に forced_login_method = "chatgpt" を設定する（例は docs/subscription_auth.md）"

exit $fail
