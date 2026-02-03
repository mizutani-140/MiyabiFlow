---
description: "PR 作成の手順をガイドし、必要なら gh を使って PR を作る"
argument-hint: "<base_branch> <title>（省略可）"
allowed-tools: Bash(git*), Bash(gh pr create*), Read
---

# /pr-open — PR を作る

## 現在のブランチ
!git branch --show-current
!git status --porcelain

## 手順
- ブランチが clean であることを確認
- `gh` がある場合は次を実行（ユーザー承認推奨）：
  `gh pr create --base <base> --title "<title>" --body-file .ai/pr/PR_BODY.md`

（このテンプレートは `.ai/pr/PR_BODY.md` を生成する想定）
