#!/usr/bin/env python3
import argparse, json, os, sys, datetime
from pathlib import Path

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--message", required=True, help="Error or stuck symptom summary")
    ap.add_argument("--context", default="", help="Optional extra context")
    args = ap.parse_args()

    project_dir = os.getcwd()
    state_path = Path(project_dir) / ".ai/state/state.json"
    state_path.parent.mkdir(parents=True, exist_ok=True)

    try:
        state = json.loads(state_path.read_text(encoding="utf-8"))
    except Exception:
        state = {}

    state.setdefault("stuck_detector", {}).setdefault("recent_failures", [])
    state["stuck_detector"]["recent_failures"].append({
        "ts": datetime.datetime.utcnow().replace(microsecond=0).isoformat()+"Z",
        "message": args.message,
        "context": args.context
    })

    # keep last 20
    state["stuck_detector"]["recent_failures"] = state["stuck_detector"]["recent_failures"][-20:]

    state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Recorded stuck symptom -> {state_path}")

if __name__ == "__main__":
    main()
