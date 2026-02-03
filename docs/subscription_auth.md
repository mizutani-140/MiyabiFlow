# [定額サブスクリプション認証] 運用（ローカル & CI）

このテンプレートは、**ローカルは原則サブスク**で運用し、
CI では必要最小限のシークレット（OAuth など）だけを使う設計です。

---

## [AIコーディングエージェントA]（Claude Code / Claude Max）

### ローカル運用
- **サブスク運用**をしたい場合は、環境変数 `ANTHROPIC_API_KEY` を **設定しない**
  - 設定されていると **[従量課金API認証]** に切り替わる可能性があります
- 初回は `claude` 起動 → 画面の案内に従い Claude アカウントでログイン

### 参考コマンド
```bash
# 現在の shell に残っていたら外す
unset ANTHROPIC_API_KEY

# 起動
claude
```

---

## [AIコーディングエージェントB]（Codex / ChatGPT Pro）

### ローカル運用
- **サブスク運用**をしたい場合は、環境変数 `OPENAI_API_KEY` を **設定しない**
- Codex CLI は、**ChatGPT アカウントでのサインイン**か、**APIキー**のどちらかで動きます
  - このテンプレートは **ChatGPT サインイン**を前提にしています

### 強制設定（推奨）
`~/.codex/config.toml` に以下を追加（なければ作成）：

```toml
# [定額サブスクリプション認証] を優先させる
forced_login_method = "chatgpt"

# OSの安全な資格情報ストアを使う（推奨）
cli_auth_credentials_store = "keyring"
```

---

## GitHub Actions での [定額サブスクリプション認証]

### Claude Code Action（OAuth）
- GitHub Actions で [AIコーディングエージェントA] を動かすには、OAuthトークン方式が便利です
- トークンはローカルで生成し、GitHub Secrets に登録します

手順は `docs/claude_github_actions_oauth.md` を参照してください。

### Codex レビュー（@codex review）
- Codex の PR レビューは **GitHub 内**で `@codex review` により実行できます（サブスク前提）
- これは **APIキー不要**で動かせるため、従量課金を避けたい運用と相性が良いです

手順は `docs/codex_github_review.md` を参照してください。
