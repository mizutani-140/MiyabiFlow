#!/usr/bin/env python3
"""Apply a plan.json to create git worktrees and write terminal assignments.

This script is intentionally conservative:
- It only creates worktrees under .worktrees/
- It creates a new branch per worktree (ai/<plan_id>/<worktree>)
- It never pushes or merges

Usage:
  python3 scripts/worktrees/apply_plan.py --plan .ai/plans/xxx_plan.json
"""

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Tuple


def run(cmd: List[str], cwd: Path | None = None) -> Tuple[int, str]:
    p = subprocess.run(cmd, cwd=str(cwd) if cwd else None, capture_output=True, text=True)
    out = (p.stdout or "") + (p.stderr or "")
    return p.returncode, out


def git_root() -> Path:
    rc, out = run(["git", "rev-parse", "--show-toplevel"])
    if rc != 0:
        raise SystemExit("Not inside a git repository")
    return Path(out.strip())


def sanitize_branch_part(s: str) -> str:
    s = s.strip().lower()
    s = re.sub(r"[^a-z0-9._/-]+", "-", s)
    s = s.strip("-.")
    s = s.replace("//", "/")
    return s[:80] or "task"


def ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def load_plan(path: Path) -> Dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or "tasks" not in data:
        raise SystemExit("Invalid plan: missing 'tasks'")
    return data


def current_branch(root: Path) -> str:
    rc, out = run(["git", "branch", "--show-current"], cwd=root)
    return out.strip() if rc == 0 else ""


def worktree_list(root: Path) -> List[Dict[str, str]]:
    rc, out = run(["git", "worktree", "list", "--porcelain"], cwd=root)
    if rc != 0:
        return []
    items: List[Dict[str, str]] = []
    cur: Dict[str, str] = {}
    for line in out.splitlines():
        if not line.strip():
            if cur:
                items.append(cur)
                cur = {}
            continue
        if " " in line:
            k, v = line.split(" ", 1)
            cur[k] = v.strip()
        else:
            cur[line.strip()] = ""
    if cur:
        items.append(cur)
    return items


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--plan", required=True, help="Path to plan json")
    ap.add_argument("--worktrees-dir", default=".worktrees", help="Directory to place worktrees")
    ap.add_argument("--base", default="", help="Base ref (default: current HEAD)")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    root = git_root()
    plan_path = (root / args.plan).resolve()
    plan = load_plan(plan_path)

    plan_id = str(plan.get("plan_id") or plan_path.stem)
    base_ref = args.base or "HEAD"

    wt_dir = root / args.worktrees_dir
    ensure_dir(wt_dir)

    existing = {Path(w.get("worktree") or w.get("path") or w.get("worktree_path") or "").resolve()
                for w in worktree_list(root) if w.get("worktree")}

    tasks = plan.get("tasks") or []
    if not isinstance(tasks, list) or not tasks:
        raise SystemExit("Plan has no tasks")

    # Create worktrees per unique worktree name
    created: List[Tuple[str, Path, str]] = []  # (task_id, path, branch)
    for t in tasks:
        if not isinstance(t, dict):
            continue
        task_id = str(t.get("id") or "").strip() or "TASK"
        worktree_name = str(t.get("worktree") or f"{task_id}")
        worktree_name = worktree_name.replace("wt/", "").replace(" ", "-")
        worktree_name = sanitize_branch_part(worktree_name).replace("/", "-")
        path = (wt_dir / worktree_name).resolve()
        owner = str(t.get("owner") or "claude").lower()

        branch = f"ai/{sanitize_branch_part(plan_id)}/{sanitize_branch_part(worktree_name)}"

        if path in existing:
            created.append((task_id, path, branch))
            continue

        cmd = ["git", "worktree", "add", "-b", branch, str(path), base_ref]
        if args.dry_run:
            print("DRY_RUN:", " ".join(cmd))
        else:
            rc, out = run(cmd, cwd=root)
            if rc != 0:
                print(out, file=sys.stderr)
                raise SystemExit(f"Failed to create worktree for {task_id} at {path}")
        created.append((task_id, path, branch))

    # Write assignments
    out_dir = root / ".ai/worktrees"
    ensure_dir(out_dir)
    assign_path = out_dir / "TERMINAL_ASSIGNMENTS.md"

    now = datetime.utcnow().replace(microsecond=0).isoformat() + "Z"
    lines: List[str] = []
    lines.append(f"# TERMINAL ASSIGNMENTS ({now})")
    lines.append("")
    lines.append("このファイルは /worktree-init により自動生成されます。\n")
    lines.append("## 0) メイン端末（統合）")
    lines.append(f"- 位置: {root}")
    lines.append("- 役割: 進捗統合、衝突解消、最終レビュー、PR作成\n")
    lines.append("## worktree 端末")
    lines.append("各端末で `cd` してから Claude Code / Codex を起動します。\n")

    for (task_id, path, branch) in created:
        rel = os.path.relpath(str(path), str(root))
        lines.append(f"### {task_id} — {rel}")
        lines.append(f"- branch: `{branch}`")
        lines.append("- 推奨: Claude Code を起動して /tdd-cycle から着手")
        lines.append("```bash")
        lines.append(f"cd {rel}")
        lines.append("claude")
        lines.append("# 次に: /tdd-cycle または /exec-verify")
        lines.append("```\n")

    assign_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"OK: wrote {assign_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
