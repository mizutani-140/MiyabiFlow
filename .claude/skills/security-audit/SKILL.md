---
name: security-audit
description: "変更差分を中心に、秘密情報・入力検証・認可・依存リスクを点検する。必要なら簡易スキャンを実行する。"
argument-hint: "[フォーカス]（例: auth|input|secrets|deps）"
allowed-tools: Read, Bash(bash scripts/security/*), Bash(git diff*), Edit, Write
---

# [目的]
AI 実装で起きやすいセキュリティ事故（秘密情報混入、入力未検証、認可漏れ）を早期に潰す。

# [チェックリスト]
- 秘密情報
  - .env / トークン / 鍵 / ハードコードが無い
- 入力検証
  - ユーザー入力、外部 I/O を検証している
- 認可
  - 権限境界がある場合、必ずガードがある
- 依存
  - 新規依存の妥当性（サイズ、ライセンス、更新頻度）

# [実行]
- `scripts/security/scan.sh` を走らせ、明らかなものを先に拾う

# [完了条件]
- P0（秘密情報、認可漏れ）が無い
- 重要な入力が検証されている
