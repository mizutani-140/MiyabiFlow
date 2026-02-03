# .claude/agents/ — [サブエージェント]（21体）運用

このディレクトリの `--- (YAML frontmatter) ---` を持つ Markdown は、
Claude Code の **[サブエージェント]** として読み込まれます。

- 目的：役割分担により **[AI自律駆動開発]** を安定化させる
- 設計：**[統括者] → [専門家]** の階層（Miyabiの思想を参考）

---

## エージェント一覧（開発向け 21）

### [統括者]
- `coordinator` … タスクDAG分解・worktree割当・進捗統括

### [計画/設計]
- `planner` … 要件→受け入れ条件→テスト戦略→DAG
- `architect` … 変更設計（境界/依存/インターフェース）
- `worktree-manager` … worktree 作成・命名・マージ戦略

### [実装/TDD]
- `tdd-red` … failing tests を書く（Red）
- `tdd-green` … 最小実装（Green）
- `refactorer` … リファクタ（Refactor）
- `debugger` … 失敗の原因切り分け

### [評価/品質]
- `reviewer` … PRレビュー（P0/P1/P2）
- `tester` … テスト実行・検証・再現スクリプト
- `security-auditor` … セキュリティ観点の監査
- `dependency-auditor` … 依存追加/更新の安全性
- `performance-auditor` … パフォーマンス観点の監査
- `ci-engineer` … CI修正・再現・高速化
- `quality-gatekeeper` … Gateを通るまで止める（merge禁止）

### [運用/リリース]
- `docs-writer` … ドキュメント更新
- `release-engineer` … リリース手順/ノート
- `observability-engineer` … ログ/メトリクス/トレース

### [補助]
- `ux-sanity-checker` … UI/UXの粗いチェック（必要時）
- `prompt-engineer` … CLAUDE.md / Skills / Agents の改善
- `codex-liaison` … [AIコーディングエージェントB] への引継ぎ・@codex review 起動

---

## 使い方（例）
- 「この変更をレビューして」→ `reviewer` が勝手に呼ばれる/指名しても良い
- 「詰まった」→ `debugger` → 直らなければ `codex-liaison` → `/codex-takeover`

> ヒント：Claude Code は `description` を見て自動委譲するので、  
> エージェント名よりも description の精度が重要です。
