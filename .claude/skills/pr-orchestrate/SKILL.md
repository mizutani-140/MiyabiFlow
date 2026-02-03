---
name: pr-orchestrate
description: "PR を作成し、CI・レビュー・説明責任（なぜこの変更か）を満たす。Codex/Claude のPRレビュー運用も含む。"
argument-hint: "[PRタイトル]（省略可）"
allowed-tools: Bash(git*), Bash(gh pr create*), Read, Write, Edit
---

# [目的]
PR を「レビュー可能な単位」に整形し、CI/CD と AI レビューを動かす。

# [手順]
1. 差分が小さいか確認（大きいなら /exec-plan に戻り分割）
2. PR 本文（背景、変更、テスト、リスク、ロールバック）を `.ai/pr/PR_BODY.md` に生成
3. CI を緑にする（/exec-verify）
4. PR を作成（gh がある場合）
5. PR コメントで Codex に指示（@codex review など）
6. 反映後、最終レビュー（/exec-review）

# [完了条件]
- PR 本文があり、テストと検証方法が書かれている
- CI が緑
- Codex/Claude レビューが実施され、指摘が処理されている
