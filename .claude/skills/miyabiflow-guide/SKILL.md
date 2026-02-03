---
name: miyabiflow-guide
description: "初心者向けにMiyabiFlow（Plan→Worktree→TDD→Verify→Review→Merge）を提案し、ターミナル分割とコピペ手順を出す。ユーザーはコマンドを打たない前提。"
argument-hint: "[やりたいこと/制約]"
allowed-tools: Read, Write, Edit, Bash(git*), Bash(ls*), Bash(find*), Bash(cat*), Bash(python3 scripts/*)
---

# [目的]
ユーザーが “何をすればいいか分からない” 状態から、最短で開発サイクルを回せるようにする。

# [前提]
- ユーザーは初心者。差分レビューをしない。
- ユーザーはターミナルにコマンドを打たない（AIが実行、ユーザーは許可クリックのみ）。
- 開発はターミナル中心（Claude Code）。
- スマホは GitHub コメント（@claude / @codex review）中心の補助。

# [出力の型]
1) 1行で要件復唱
2) 推奨ターミナル分割（3分割/2分割/1つのいずれか1つを推奨として提示）
3) worktree前提のタスク分解（1〜3時間単位、3〜7タスク）
4) 重要な承認ゲート（最大3つ、必要な場合のみ）
5) コピペパック（統括端末・実装端末・スマホ用コメント・承認返信テンプレ）
