#!/usr/bin/env python3
"""waybar custom module: Codex rate-limit reset time, read from local session logs."""
import glob
import json
import os
import sys
import time

ROOT = os.path.expanduser("~/.codex/sessions")


def out(text, tooltip="", cls=""):
    print(json.dumps({"text": text, "tooltip": tooltip, "class": cls}, ensure_ascii=False))
    sys.exit(0)


def fmt(sec):
    sec = int(sec)
    if sec <= 0:
        return "0m"
    d, r = divmod(sec, 86400)
    h, r = divmod(r, 3600)
    m = r // 60
    return f"{d}d{h}h" if d else (f"{h}h{m:02d}m" if h else f"{m}m")


if not os.path.isdir(ROOT):
    out("codex n/a", "~/.codex not found (codex not installed or never run)", "warning")

files = sorted(glob.glob(os.path.join(ROOT, "**", "*.jsonl"), recursive=True),
               key=os.path.getmtime, reverse=True)[:5]
limits, stamp = None, 0
for path in files:
    try:
        with open(path) as f:
            for line in f:
                if '"rate_limits"' not in line:
                    continue
                try:
                    ev = json.loads(line)
                except ValueError:
                    continue
                rl = (ev.get("payload") or {}).get("rate_limits")
                if rl:
                    limits, stamp = rl, os.path.getmtime(path)
    except OSError:
        continue
    if limits:
        break

if not limits:
    out("codex idle", "no rate-limit info in recent sessions")

display, tip = None, []
for key, label in (("primary", "5h"), ("secondary", "7d")):
    w = limits.get(key) or {}
    left = None
    if w.get("resets_at"):
        left = w["resets_at"] - time.time()
    elif w.get("resets_in_seconds") is not None:
        left = w["resets_in_seconds"] - (time.time() - stamp)
    used = w.get("used_percent")
    if left is not None and left > 0 and used is not None:
        rem = max(0, round(100 - used))
        reset = fmt(left)
        tip.append(f"{label}: {rem}% left ({used}% used), resets in {reset}")
        if key == "primary" or used >= 100:
            display = f"{rem}% {reset}"

if display is None:
    out("codex idle", "\n".join(tip) or "no active usage window in recent sessions")

out(f"<span font_family='DejaVu Sans' foreground='#4cc9f0'>⌘</span> {display}",
    "\n".join(tip))
