# 03 接続・連携 — GitHub / Claude Code / Codex（初心者向け・詳細）

この章は「どこを繋げば、コマンド無しで回るか」を **できるだけクリック手順**で説明します。

---

## 1) Claude Code とプロジェクト（必須）
やること:
1. Claude Code を起動
2. **プロジェクトフォルダ**を開く
3. 「ツール実行（Bash）」の許可を求められたら **許可**

これで、あなたがコマンドを打たなくても、Claude Code が代わりに:
- git操作（ブランチ、コミット、worktree）
- テスト実行（make ci）
を実行できます（あなたは **許可をクリック**するだけ）。

---

## 2) Codex と GitHub（おすすめ：これが一番ラク）
目的:
- PR上で `@codex review` すると、自動でレビューしてくれる状態にする

### 2-1. Codex 側で GitHub を接続（クリック）
Codex の環境設定を開き、GitHub を接続します。

（参考URLは“コピペ用”としてコードブロックに入れています）
```text
chatgpt.com/codex
```

一般的な流れ:
1) Codex の設定（Settings / Environment settings）を開く  
2) “GitHub” を選び、接続（Connect）  
3) リポジトリへのアクセス許可を行う（必要なら Organizations も）

> ここは **あなたがログインして許可**する必要があります（AIではできません）。

### 2-2. “Code review” をリポジトリで ON（クリック）
Codex settings で、対象リポジトリの “Code review” を ON にします。

一般的な流れ:
1) Codex settings を開く  
2) GitHub のセクションを探す  
3) 対象リポジトリのトグル（Code review）をON

### 2-3. PRでレビュー依頼（コマンド不要）
GitHubのPRのコメント欄に、これだけ書きます:
- `@codex review`

---

## 3) GitHub Actions（CI）と GitHub（必須に近い）
目的:
- PR作成時に `make ci` が自動で実行されるようにする

やること:
- `.github/workflows/ci.yml` がリポジトリに入っていること
- GitHub の Actions が ON であること（通常はデフォルトON）

---

## 4) Claude Code Action（CCA）と GitHub（任意）
目的:
- PRに対して Claude 側のレビュー（例: `/review`）を自動で走らせる

やること（クリック）:
1) GitHub リポジトリ → **Settings**
2) **Secrets and variables** → **Actions**
3) **New repository secret**
4) Name: `CLAUDE_CODE_OAUTH_TOKEN`
5) Value: （Claude Code が発行したトークン）
6) Save

> これは “あると便利” ですが、最初の1周には必須ではありません。

---

## 5) 「Claude Code ⇄ Codex」を同じPCで直結したい場合（上級・任意）
目的:
- Claude Code から Codex を “道具” のように呼ぶ（MCP）

注意:
- 導入が一段難しくなります。初心者はまず 2) の **GitHub経由**でOKです。
- 必要なら Claude Code に次を頼みます（あなたは許可クリックだけ）:
  - `.mcp.json` の作成
  - MCPサーバの起動確認
  - Codex連携の動作確認（レビュー用途から）
