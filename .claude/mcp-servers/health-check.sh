#!/usr/bin/env bash
set -euo pipefail

echo "[mcp] repo: $(git rev-parse --show-toplevel 2>/dev/null || pwd)"
echo "[mcp] node: $(node --version 2>/dev/null || echo 'NOT FOUND')"
echo "[mcp] codex: $(command -v codex >/dev/null 2>&1 && echo OK || echo 'NOT FOUND')"

if [[ ! -d ".claude/mcp-servers/node_modules/@modelcontextprotocol" ]]; then
  echo "[mcp] NOTE: dependencies not installed. Run:"
  echo "  cd .claude/mcp-servers && npm install"
fi

echo "[mcp] configured servers in .mcp.json:"
python3 - <<'PY'
import json,sys,os
p=".mcp.json"
try:
    d=json.load(open(p,"r",encoding="utf-8"))
except Exception as e:
    print("  (unable to read .mcp.json)")
    sys.exit(0)
servers=d.get("mcpServers",{})
for k,v in servers.items():
    if isinstance(v, dict) and v.get("disabled"):
        print(f"  - {k} (disabled)")
    else:
        print(f"  - {k}")
PY
