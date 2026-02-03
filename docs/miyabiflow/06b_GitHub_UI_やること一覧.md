# 06b GitHub UI でユーザーがやること一覧（初心者向け）

このファイルは **“クリックでやること”** を全部まとめたものです。  
（コマンドは不要です）

---

## 1) リポジトリ作成（最初だけ）
- GitHubで New repository → 作成
- Public/Private は好み（会社/チームならPrivate推奨）

---

## 2) GitHub Actions（CI）を使う
### 確認
- リポジトリ上部の “Actions” タブが見える → OK

### もしActionsが無効な場合（稀）
- Settings → Actions → General → Allow（許可）を有効化

---

## 3) ブランチ保護（推奨：事故防止）
Settings → Branches → Add branch protection rule

おすすめ設定:
- “Require a pull request before merging”
- “Require approvals”（最低1）
- “Require status checks to pass before merging”
  - `CI`（あなたの `ci.yml` のジョブ名）をチェックに入れる

---

## 4) PRテンプレを使う
PR作成画面でテンプレが出たら、そのまま埋める  
（文章は Claude Code に作らせてコピペでOK）

---

## 5) Codexレビューを有効化（おすすめ）
- Codex settings で対象リポジトリの “Code review” を ON
- PRコメントで `@codex review`

---

## 6) Claude Code Action（任意）
Settings → Secrets and variables → Actions → New repository secret
- `CLAUDE_CODE_OAUTH_TOKEN` を追加
