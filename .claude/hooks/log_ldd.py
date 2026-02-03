#!/usr/bin/env python3
import json, os, sys, datetime, pathlib

RAW = sys.stdin.read()
now = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"

try:
    payload = json.loads(RAW) if RAW.strip() else {}
except json.JSONDecodeError:
    payload = {"hook_event_name": "UNKNOWN", "raw": RAW}

project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
log_dir = pathlib.Path(project_dir) / os.environ.get("AI_DEV_LOG_DIR", ".ai/logs")
log_dir.mkdir(parents=True, exist_ok=True)

session_id = payload.get("session_id") or "unknown-session"
event = payload.get("hook_event_name") or "UNKNOWN"

out = {
    "ts": now,
    "event": event,
    "session_id": session_id,
    "cwd": payload.get("cwd"),
    "permission_mode": payload.get("permission_mode"),
    "tool_name": payload.get("tool_name"),
    "tool_input": payload.get("tool_input"),
    "tool_response": payload.get("tool_response"),
    "prompt": payload.get("prompt"),
    "stop_hook_active": payload.get("stop_hook_active"),
}

# Write JSONL
jsonl_path = log_dir / f"ldd_{session_id}.jsonl"
with jsonl_path.open("a", encoding="utf-8") as f:
    f.write(json.dumps(out, ensure_ascii=False) + "\n")

# Also append a human-friendly markdown log (best-effort)
md_path = log_dir / f"ldd_{session_id}.md"
def md_escape(s: str) -> str:
    return s.replace("```", "``\u0060")

lines = []
lines.append(f"\n## {now} [{event}]")
if out.get("prompt"):
    lines.append("\n### UserPrompt\n```\n" + md_escape(out["prompt"]) + "\n```")
if out.get("tool_name") == "Bash":
    cmd = (out.get("tool_input") or {}).get("command")
    if cmd:
        lines.append("\n### Bash\n```bash\n" + md_escape(cmd) + "\n```")
if out.get("tool_name") in ("Write", "Edit"):
    fp = (out.get("tool_input") or {}).get("file_path")
    if fp:
        lines.append(f"\n### File\n- {fp}")
if out.get("tool_response"):
    lines.append("\n### ToolResponse\n```json\n" + md_escape(json.dumps(out["tool_response"], ensure_ascii=False, indent=2)) + "\n```")

with md_path.open("a", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

sys.exit(0)
