#!/usr/bin/env python3
import json, os, re, sys

# PreToolUse hook for Bash
# - Reads hook input JSON from stdin
# - Blocks dangerous commands via exit code 2

RAW = sys.stdin.read()
try:
    payload = json.loads(RAW) if RAW.strip() else {}
except json.JSONDecodeError:
    print("Invalid hook input JSON", file=sys.stderr)
    sys.exit(2)

cmd = (payload.get("tool_input") or {}).get("command") or ""

# Allow empty
if not cmd.strip():
    sys.exit(0)

danger_patterns = [
    r"\brm\s+-rf\b",
    r"\bmkfs\b",
    r"\bdd\b\s+if=",
    r"\bshutdown\b|\breboot\b",
    r"\bsudo\b",
    r"\bcurl\b\s+http",
    r"\bwget\b\s+http",
    r"\bssh\b\s+",
    r"\bchmod\b\s+777\b",
    r":\(\)\s*\{\s*:\|:\&\s*\}\s*;\s*:"  # fork bomb
]

for pat in danger_patterns:
    if re.search(pat, cmd, flags=re.IGNORECASE):
        print(f"[決定論フック] Blocked dangerous command: {cmd}", file=sys.stderr)
        print("If this is intentional, run it manually outside Claude Code or adjust .claude/settings.local.json.", file=sys.stderr)
        sys.exit(2)

# Additionally block writing outside project by '>' redirection to /etc, /usr, ~/.ssh etc
redir_pat = r">\s*(/etc/|/usr/|/bin/|/sbin/|/var/|~/.ssh/)"
if re.search(redir_pat, cmd):
    print(f"[決定論フック] Blocked redirect to protected path: {cmd}", file=sys.stderr)
    sys.exit(2)

sys.exit(0)
