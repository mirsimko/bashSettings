#!/bin/bash
# Minimal one-line statusline:
#   ctx: 4% (41k/1000k) | Opus 4.8 (1M context) | owner.name | branch | 5h: 15% (→12:50) | wk: 4% (→Sat 04:00)
# Fields come from the statusLine JSON on stdin; git branch + owner.name are derived via git.
input=$(cat)
printf '%s' "$input" | python3 -c '
import json, sys, os, subprocess, datetime

d = json.load(sys.stdin)

# --- ANSI helpers -----------------------------------------------------------
RESET = "\033[0m"
DIM   = "\033[2m"
SEP_C = "\033[90m"      # dim gray separators / static text
BLUE  = "\033[1;34m"    # path / project (bold blue)
GREEN = "\033[32m"      # git branch

def pct_color(p):
    # green when low, yellow mid, red high — useful for ctx and limits
    if p >= 80: return "\033[31m"
    if p >= 60: return "\033[33m"
    return "\033[32m"

segs = []

# --- ctx: used% (usedk/sizek) ----------------------------------------------
cw = d.get("context_window") or {}
used_pct = cw.get("used_percentage")
size = cw.get("context_window_size")
if used_pct is not None and size:
    used_k = round(size * used_pct / 100 / 1000)
    size_k = round(size / 1000)
    c = pct_color(used_pct)
    segs.append(f"{DIM}ctx:{RESET} {c}{used_pct:.0f}%{RESET} {DIM}({used_k}k/{size_k}k){RESET}")

# --- model (context size) ---------------------------------------------------
model = (d.get("model") or {}).get("display_name", "")
if model:
    if size and size >= 1_000_000:
        human = f"{size/1_000_000:g}M"
    elif size:
        human = f"{round(size/1000)}K"
    else:
        human = ""
    label = f"{model} ({human} context)" if human else model
    segs.append(f"{DIM}{label}{RESET}")

# --- owner.name project label (JSON repo, fallback git origin, fallback dir) -
cwd = d.get("cwd") or (d.get("workspace") or {}).get("current_dir") or os.getcwd()

def git(args):
    try:
        return subprocess.run(["git", "-C", cwd] + args, capture_output=True,
                              text=True, timeout=1).stdout.strip()
    except Exception:
        return ""

repo = (d.get("workspace") or {}).get("repo") or {}
owner, name = repo.get("owner"), repo.get("name")
if not (owner and name):
    url = git(["remote", "get-url", "origin"])
    if url:
        tail = url.split(":")[-1] if ":" in url and "//" not in url else url.split("/", 3)[-1] if "//" in url else url
        tail = tail[:-4] if tail.endswith(".git") else tail
        parts = [p for p in tail.split("/") if p]
        if len(parts) >= 2:
            owner, name = parts[-2], parts[-1]
proj = f"{owner}.{name}" if owner and name else os.path.basename(cwd.rstrip("/"))
if proj:
    segs.append(f"{BLUE}{proj}{RESET}")

# --- git branch -------------------------------------------------------------
branch = git(["rev-parse", "--abbrev-ref", "HEAD"])
if branch:
    segs.append(f"{GREEN}{branch}{RESET}")

# --- 5h / weekly limits (Pro/Max, after first API response) -----------------
rl = d.get("rate_limits") or {}

def limit_seg(label, window, time_fmt):
    w = rl.get(window) or {}
    p = w.get("used_percentage")
    if p is None:
        return None
    reset = ""
    ts = w.get("resets_at")
    if ts:
        try:
            reset = f" {DIM}(→{datetime.datetime.fromtimestamp(ts).strftime(time_fmt)}){RESET}"
        except Exception:
            reset = ""
    c = pct_color(p)
    return f"{DIM}{label}:{RESET} {c}{p:.0f}%{RESET}{reset}"

for seg in (limit_seg("5h", "five_hour", "%H:%M"),
            limit_seg("wk", "seven_day", "%a %H:%M")):
    if seg:
        segs.append(seg)

# --- join -------------------------------------------------------------------
sep = f"{SEP_C}  |  {RESET}"
sys.stdout.write(sep.join(segs))
'
