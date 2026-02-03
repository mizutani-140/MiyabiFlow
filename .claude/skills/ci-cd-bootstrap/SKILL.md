---
name: ci-cd-bootstrap
description: "本番運用レベルのCI/CD（GitHub Actions）とローカル検証入口を整える。TDD前提で 'make ci' または scripts/ci/run_ci.sh を標準化する。"
argument-hint: "[言語/フレームワーク]（省略可）"
allowed-tools: Read, Write, Edit, Bash(ls*), Bash(cat*), Bash(git diff*)
---

# [目的]
AI 自律駆動開発が破綻しないよう、必ず CI/CD を整備する。

# [原則]
- ローカルの入口を 1つにする：`scripts/ci/run_ci.sh --mode ci`
- CI も同じ入口を呼ぶ（差を作らない）
- TDD を妨げない速度感（遅いテストは分離）

# [やること]
1. `scripts/ci/run_ci.sh` をプロジェクトに合わせて調整
2. `.github/workflows/ci.yml` が `scripts/ci/run_ci.sh` を呼ぶようにする
3. `AGENTS.md`（Codex）と `CLAUDE.md`（Claude）に CI 要件を明記
4. 追加で必要なら：
   - 依存キャッシュ
   - マトリクス（node/python versions）
   - セキュリティスキャン（秘密情報検出）

# [完了条件]
- GitHub Actions の CI が緑
- ローカルで同じコマンドが通る
- 失敗時のログが追える（`.ai/reports` など）
