# Hooks（Claude Code）

このディレクトリは、Claude Code の `hooks`（`.claude/settings.json`）で実行されるスクリプト群です。

## 目的
- [安全] 危険な Bash をブロックして事故を防ぐ
- [再現性] 作業ログを保存して「何をしたか」を追えるようにする
- [品質] CI が赤い状態で「完了」と言わない（Stop 品質ゲート）

## スクリプト

- `bash_guard.py`
  - イベント: `PreToolUse`（Bash）
  - 役割: 明らかに危険なコマンド（rm -rf / sudo / mkfs / curl http 等）を exit 2 でブロック

- `log_ldd.py`
  - イベント: `UserPromptSubmit` / `PostToolUse`
  - 役割: LDD（Log-Driven Development）として、入力・ツール実行のメタ情報を `.ai/logs/` に保存

- `stop_quality_gate.sh`
  - イベント: `Stop`
  - 役割: `scripts/ci/run_ci.sh --mode ci` を優先し、無ければ `make ci` を実行。
          CI が失敗なら exit 2 で停止させず修正を継続

- `session_end.py`
  - イベント: `SessionEnd`
  - 役割: セッション終了時の簡易レポートを `.ai/reports/` に保存

## 注意
- hooks は強力です。チームで共有する設定は「破壊的操作が起きない」ように保守してください。
