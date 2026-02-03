#!/usr/bin/env python3
import json, os, sys, datetime, pathlib

RAW = sys.stdin.read()
now = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"

try:
    payload = json.loads(RAW) if RAW.strip() else {}
except json.JSONDecodeError:
    payload = {"hook_event_name": "UNKNOWN", "raw": RAW}

project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
metrics_dir = pathlib.Path(project_dir) / ".ai/metrics"
metrics_dir.mkdir(parents=True, exist_ok=True)

event = payload.get("hook_event_name") or "UNKNOWN"
session_id = payload.get("session_id") or "unknown-session"

record = {
    "ts": now,
    "event": event,
    "session_id": session_id,
    "agent_id": payload.get("agent_id"),
    "agent_type": payload.get("agent_type"),
    "agent_transcript_path": payload.get("agent_transcript_path"),
}

with (metrics_dir / "agent_events.jsonl").open("a", encoding="utf-8") as f:
    f.write(json.dumps(record, ensure_ascii=False) + "\n")

# Optional webhook
webhook = os.environ.get("AI_EVENT_WEBHOOK_URL", "").strip()
if webhook:
    try:
        import urllib.request
        req = urllib.request.Request(
            webhook,
            data=json.dumps(record, ensure_ascii=False).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        urllib.request.urlopen(req, timeout=3).read()
    except Exception:
        # Non-fatal: webhook failure should not break the session
        pass

sys.exit(0)
