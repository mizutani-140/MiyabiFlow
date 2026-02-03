#!/usr/bin/env python3
"""Generate a Task DAG plan JSON.

This script supports 2 modes:
- --skeleton: create a minimal plan scaffold
- --llm: attempt to call an external CLI (claude/codex) to produce a plan (optional)

The output is written under .ai/plans/.
"""
import argparse, datetime, json, os, re, subprocess, sys
from pathlib import Path

def slugify(s: str) -> str:
    s = s.strip().lower()
    s = re.sub(r"[^a-z0-9]+", "-", s)
    return s.strip("-")[:60] or "plan"

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("title", help="Plan title (short)")
    ap.add_argument("--source", default="", help="Original requirement/issue text")
    ap.add_argument("--skeleton", action="store_true", help="Generate a skeleton plan without calling LLM")
    ap.add_argument("--llm", choices=["claude", "codex"], help="Try to call claude/codex CLI to generate a plan JSON")
    args = ap.parse_args()

    project = Path(os.getcwd())
    out_dir = project / ".ai/plans"
    out_dir.mkdir(parents=True, exist_ok=True)

    now = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"
    base = {
        "meta": {"title": args.title, "created_at": now, "source": args.source},
        "abstraction": {
            "Claude Code": "[AIコーディングエージェントA]",
            "Codex": "[AIコーディングエージェントB]",
            "git worktree": "[並列作業ツリー]",
            "CI/CD": "[品質ゲート付きデリバリーパイプライン]",
            "TDD": "[テスト先行反復手順]"
        },
        "tasks": [
            {
                "id": "T1",
                "title": "Write failing tests (Red)",
                "agent": "claude",
                "worktree": "T1-red-tests",
                "depends_on": [],
                "dod": ["Failing test added", "Explains expected behavior"],
                "commands": ["make test"]
            },
            {
                "id": "T2",
                "title": "Implement minimal fix (Green) and refactor",
                "agent": "claude",
                "worktree": "T2-green-impl",
                "depends_on": ["T1"],
                "dod": ["Tests pass", "Refactor done", "make ci passes"],
                "commands": ["make ci"]
            },
            {
                "id": "T3",
                "title": "Codex review and edge-case verification",
                "agent": "codex",
                "worktree": "T3-review",
                "depends_on": ["T2"],
                "dod": ["P0/P1 issues resolved or accepted", "Score >= 80"],
                "commands": []
            }
        ]
    }

    plan = base

    if args.llm and not args.skeleton:
        prompt = f"""You are a planning agent. Produce ONLY valid JSON matching this schema idea:
- meta(title, created_at, source)
- abstraction: map concrete-> [AbstractLabel]
- tasks: list of tasks with id, title, agent(claude|codex|human), worktree, depends_on, dod, commands

Requirement:
{args.source}

Constraints:
- TDD-first
- worktree parallelism
- include failover rule: if claude fails 3 times, codex takes over
Return JSON only.
"""
        try:
            if args.llm == "claude":
                # Requires claude CLI with -p (print) support.
                res = subprocess.check_output(["claude", "-p", prompt], text=True)
                plan = json.loads(res)
            elif args.llm == "codex":
                res = subprocess.check_output(["codex", "exec", prompt], text=True)
                plan = json.loads(res)
        except Exception as e:
            print(f"[warn] LLM plan generation failed, using skeleton. reason={e}", file=sys.stderr)
            plan = base

    fname = f"{datetime.datetime.utcnow().strftime('%Y%m%d_%H%M%S')}_{slugify(args.title)}.plan.json"
    out_path = out_dir / fname
    out_path.write_text(json.dumps(plan, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(str(out_path))

if __name__ == "__main__":
    main()
