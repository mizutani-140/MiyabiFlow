# MIYABIFLOW COPYPASTE KIT（テンプレ v2）

このファイルは `/miyabiflow` 実行時に `.ai/worktrees/MIYABIFLOW_COPYPASTE.md` として保存される想定です。

> ルール: **毎回必ず3セット**（Issue / Claude Code / PRコメント）を作る。

---

## セット1: そのままIssueに貼れる（スマホ）

```text
@claude
MiyabiFlow（雅フロー）で進めたいです。私は初心者で、ターミナルにコマンドを打ちません。
（ここに要件）
制約:
- TDD（テスト駆動開発）中心
- `make ci` を品質ゲートにして必ず通す
- worktree/ブランチ分割で並列化（最大2〜3）
- 重要な承認が必要な場合だけ、A/Bで理由付き提案してほしい
```

---

## セット2: そのままClaude Codeに貼れる（ターミナル）

### [統括端末] に貼る
```text
（ここに日本語指示: Plan→worktree→PR作成、承認ゲート含む）
```

### [実装端末] に貼る
```text
（ここに日本語指示: タスクT01開始、TDD、make ci）
```

### [検証端末] に貼る（3分割のとき）
```text
（ここに日本語指示: CI確認、@codex review依頼、P0/P1修正の整理）
```

---

## セット3: そのままPRコメントに貼れる（スマホ or PC）

### Codexレビュー
```text
@codex review
```

### （任意）Claudeへ修正依頼（CCAが有効な場合）
```text
@claude
@codex review のP0/P1を優先して修正し、`make ci` を通してください。修正後に要約もください。
```

---

## 承認返信テンプレ（短文）
```text
AでOK
```
