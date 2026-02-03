# Repository Guidelines

## Project Structure & Module Organization
This repository is a template for AI-assisted development and CI automation.

- `.claude/` — Claude Code settings, prompts, hooks, and MCP config.
- `.ai/` — generated plans/state plus optional CI config in `.ai/config/ci.json`.
- `scripts/` — CI, security, Codex, worktree, and MiyabiFlow helpers.
- `tools/` — shared CI/format/orchestrator utilities.
- `docs/` — MiyabiFlow documentation and onboarding guides.
- `.github/workflows/` — GitHub Actions pipelines.

## Build, Test, and Development Commands
```bash
make ci                    # lint → typecheck → test via scripts/ci/run_ci.sh
make test                  # test-only mode
make security              # security scan (scripts/security/scan.sh)
bash scripts/ci/run_ci.sh --mode ci
bash scripts/ci/run_ci.sh --mode test-only
```
Customize CI commands by adding `.ai/config/ci.json` (see `.ai/config/ci.example.json`).

## Coding Style & Naming Conventions
- Follow existing file style; keep diffs small and readable.
- Python uses 4-space indentation and `snake_case` (e.g., `cleanup_worktrees.py`).
- Shell scripts are `bash` with lower_snake_case filenames.
- No formatter is wired by default; add one in `tools/ci/format.sh` and reference it from CI.

## Testing Guidelines
- This template is framework-agnostic; add tests in your stack’s standard location (e.g., `tests/` for Python, `__tests__/` for Node).
- Wire test commands in `.ai/config/ci.json` so `make test` and `make ci` pick them up.
- Prefer fast unit tests locally; reserve full suites for CI.

## Commit & Pull Request Guidelines
- Git history is not included in this snapshot; use concise, imperative commit messages (e.g., “Add CI config loader”).
- If your team uses Conventional Commits, keep `feat:`/`fix:`/`chore:` prefixes consistent.
- PRs should include a short summary, testing notes (commands + results), and linked issues; add screenshots for UI changes.

## Security & Configuration Tips
- Run `make security` before release or major changes.
- Keep secrets out of the repo; use local env files or CI secrets.
