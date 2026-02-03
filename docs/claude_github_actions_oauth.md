# [AIコーディングエージェントA]（Claude Code）を GitHub Actions でサブスク運用する（OAuth）

このテンプレートは、GitHub Actions で Claude Code を動かす際も、
可能な限り **[定額サブスクリプション認証]** を維持できるように設計しています。

---

## 概要
- GitHub Actions の Claude Code Action は、**APIキー方式**と **OAuth トークン方式**が存在します
- このテンプレートは **OAuth トークン方式**をデフォルトにします

---

## 手順（最短）
1. ローカルで Claude Code をログイン済みにする
2. OAuth トークンを生成する

```bash
# 例（環境によっては /install-github-app でもOK）
claude setup-token
```

3. GitHub リポジトリにシークレットを追加  
   - `Settings` → `Secrets and variables` → `Actions` → `New repository secret`
   - 名前: `CLAUDE_CODE_OAUTH_TOKEN`
   - 値: 生成したトークン

4. `.github/workflows/ai_claude.yml` を有効化（このテンプレートに同梱）

---

## セキュリティ注意
- `pull_request_target` を使う自動化は、フォークからのPRで危険になり得ます  
  このテンプレートは、**フォークPRでは書き込み系を実行しない**ガードを入れています
- Claude が作った変更も、最終的には人間が承認する前提にしています（CODEOWNERS推奨）
