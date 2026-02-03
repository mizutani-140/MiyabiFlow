# QUICK START（Claude Code × Codex × worktree）

## 0) 前提（サブスク運用）

- Claude Code：Claude Max（または Pro）で `claude` をログインして使う
- Codex：ChatGPT Pro（または同等）で `codex` をログインして使う

重要：このテンプレートは「従量課金 API キーが無くても回る」構成をデフォルトにしています。

## 1) インストールとログイン

### Claude Code
- Claude Code をインストール
- `claude` を起動し、Claude.ai アカウントでログイン

### Codex CLI
- `codex` をインストール（Homebrew / npm など）
- `codex login`（または `codex login --device-auth`）でログイン

## 2) リポジトリにテンプレートを配置

この zip をプロジェクトルートに展開し、以下が存在することを確認：

- `.claude/`
- `.mcp.json`
- `.github/workflows/`
- `AGENTS.md`
- `CLAUDE.md`

## 3) Claude Code を起動（メイン worktree）

### 最短: MiyabiFlow
- `/.miyabiflow <やりたいこと>` を実行（提案→Plan→コピペパック生成）
- その後、案内に従って `/.worktree-init <plan>`


プロジェクトルートで：

1. `claude` を起動
2. `/.exec-plan` で計画とタスク分解（worktree マップを生成）
3. `/.worktree-init` で worktree を作成
4. 生成された `.ai/worktrees/TERMINAL_ASSIGNMENTS.md` に従って、別端末を開いて各 worktree に入る

## 4) TDD を回す（各 worktree）

各 worktree 端末で：

- `/.tdd-cycle` を実行し、Red→Green→Refactor を徹底
- 小さくコミット（または PR 用にまとめてコミット）
- `/.exec-verify` でローカル検証（= CI と同等のコマンドを走らせる）

## 5) Codex に評価させる

### ローカル（CLI）
- `/.codex-review`：差分レビュー
- `/.codex-test`：テスト追加・テスト戦略の提案

### GitHub（PR）
- PR コメントに `@codex review`（自動レビュー）
- CI が落ちたら `@codex fix the CI failures` で Codex タスク起動

## 6) 品質ゲート（自動）

Stop hook が有効な場合：
- Claude が「完了」と言う前に `make ci` または `scripts/ci/run_ci.sh` を実行し、
  失敗なら停止させず修正を継続します。
