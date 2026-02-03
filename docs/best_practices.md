# ベストプラクティス

- まず `/exec-plan` で “分割” する（分割しない自律は事故る）
- 1タスク=1 worktree を守る（統合が楽）
- “CIが赤いまま” は成果物ではない（品質ゲート）
  - `bash scripts/ci/run_ci.sh --mode ci` または `make ci`
- AIレビューは **補助**。最終判断は人間（[人間承認]）が行う
- 2回詰まったら `/codex-takeover`（停滞の長期化を避ける）
