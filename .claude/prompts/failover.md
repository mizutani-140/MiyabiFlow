# Failover Protocol (Claude → Codex)

目的：Claude Code が停滞したときに、[AIコーディングエージェントB]=Codex に引き継いで最短で復帰する。

## いつ切り替えるか
- 同じエラーを 2回以上繰り返す
- CI の失敗原因が環境依存で追えない
- テスト設計が困難で前に進まない

## 手順
1. 現象を 1〜2文で要約する
2. handoff packet を作る
   - `/codex-takeover <要約>` または `bash scripts/codex/takeover.sh "<要約>"`
3. Codex の出力を受け取り、最小パッチとして取り込む
4. `bash scripts/ci/run_ci.sh --mode ci` を通す
5. 変更理由を PR 本文（`.ai/pr/PR_BODY.md` など）に反映する
