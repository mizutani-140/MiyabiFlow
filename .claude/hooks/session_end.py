#!/usr/bin/env python3
import json, os, sys, datetime, pathlib

RAW = sys.stdin.read()
now = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"
try:
    payload = json.loads(RAW) if RAW.strip() else {}
except json.JSONDecodeError:
    payload = {"hook_event_name": "SessionEnd", "raw": RAW}

project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
reports_dir = pathlib.Path(project_dir) / ".ai/reports"
reports_dir.mkdir(parents=True, exist_ok=True)

session_id = payload.get("session_id") or "unknown-session"
reason = payload.get("reason") or "other"

summary = {
    "ts": now,
    "session_id": session_id,
    "reason": reason,
    "transcript_path": payload.get("transcript_path"),
}

with (reports_dir / f"session_end_{session_id}.json").open("w", encoding="utf-8") as f:
    f.write(json.dumps(summary, ensure_ascii=False, indent=2) + "\n")

sys.exit(0)
