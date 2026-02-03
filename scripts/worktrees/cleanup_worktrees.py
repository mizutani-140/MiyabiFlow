#!/usr/bin/env python3
"""Remove generated worktrees under .worktrees/.

Usage:
  python3 scripts/worktrees/cleanup_worktrees.py --yes
"""

import argparse
import subprocess
import sys
from pathlib import Path
from typing import List, Dict


def run(cmd: List[str], cwd: Path | None = None) -> int:
    p = subprocess.run(cmd, cwd=str(cwd) if cwd else None)
    return p.returncode


def capture(cmd: List[str], cwd: Path | None = None) -> str:
    p = subprocess.run(cmd, cwd=str(cwd) if cwd else None, capture_output=True, text=True)
    return (p.stdout or "") + (p.stderr or "")


def git_root() -> Path:
    out = capture(["git", "rev-parse", "--show-toplevel"]).strip()
    if not out:
        raise SystemExit("Not inside a git repository")
    return Path(out)


def list_worktrees(root: Path) -> List[Path]:
    out = capture(["git", "worktree", "list", "--porcelain"], cwd=root)
    paths: List[Path] = []
    for line in out.splitlines():
        if line.startswith("worktree "):
            p = line.split(" ", 1)[1].strip()
            if p:
                paths.append(Path(p).resolve())
    return paths


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--yes", action="store_true", help="Do not prompt")
    ap.add_argument("--worktrees-dir", default=".worktrees")
    args = ap.parse_args()

    root = git_root()
    wt_base = (root / args.worktrees_dir).resolve()
    if not wt_base.exists():
        print("No .worktrees directory; nothing to do")
        return 0

    wts = list_worktrees(root)
    targets = [p for p in wts if str(p).startswith(str(wt_base) + "/")]

    if not targets:
        print("No generated worktrees found under .worktrees/")
        return 0

    if not args.yes:
        print("The following worktrees will be removed:")
        for p in targets:
            print(" -", p)
        resp = input("Proceed? [y/N] ").strip().lower()
        if resp not in ("y", "yes"):
            print("Aborted")
            return 1

    for p in targets:
        print("Removing", p)
        rc = run(["git", "worktree", "remove", "--force", str(p)], cwd=root)
        if rc != 0:
            print("Failed to remove", p, file=sys.stderr)
            return rc

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
