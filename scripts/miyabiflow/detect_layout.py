#!/usr/bin/env python3
"""Detect a reasonable terminal split recommendation for MiyabiFlow.

This is a best-effort heuristic. It does NOT require platform-specific dependencies.
Inputs (optional):
- MIYABIFLOW_LAYOUT: "1"|"2"|"3" to force recommendation
- MIYABIFLOW_MONITORS: integer; if >=2 we bias to 3
Outputs:
- Human-readable summary
- JSON blob (for tools/parsing)
"""
from __future__ import annotations

import json
import os
import shutil
from datetime import datetime


def clamp(n: int, lo: int, hi: int) -> int:
    return max(lo, min(hi, n))


def main() -> None:
    cols, lines = shutil.get_terminal_size(fallback=(120, 30))
    tmux = bool(os.environ.get("TMUX"))
    forced = os.environ.get("MIYABIFLOW_LAYOUT", "").strip()
    monitors_raw = os.environ.get("MIYABIFLOW_MONITORS", "").strip()

    monitors = 0
    if monitors_raw:
        try:
            monitors = int(monitors_raw)
        except ValueError:
            monitors = 0

    recommended = None
    reason = ""

    if forced in {"1", "2", "3"}:
        recommended = int(forced)
        reason = "forced by MIYABIFLOW_LAYOUT"
    else:
        # Heuristic:
        # - Multi-monitor (>=2): 3
        # - Wide terminal: 3
        # - Medium: 2
        # - Small: 1
        if monitors >= 2:
            recommended = 3
            reason = "multi-monitor bias (MIYABIFLOW_MONITORS>=2)"
        elif cols >= 170:
            recommended = 3
            reason = "wide terminal (cols>=170)"
        elif cols >= 120:
            recommended = 2
            reason = "medium terminal (cols>=120)"
        else:
            recommended = 1
            reason = "small terminal (cols<120)"

    recommended = clamp(int(recommended), 1, 3)

    payload = {
        "ts": datetime.utcnow().replace(microsecond=0).isoformat() + "Z",
        "cols": cols,
        "lines": lines,
        "tmux": tmux,
        "monitors": monitors,
        "recommended": recommended,
        "reason": reason,
    }

    print(f"[MiyabiFlow] layout detection: cols={cols}, lines={lines}, tmux={tmux}, monitors={monitors}")
    print(f"[MiyabiFlow] recommended split: {recommended} (reason: {reason})")
    print("----JSON----")
    print(json.dumps(payload, ensure_ascii=False))

if __name__ == "__main__":
    main()
