#!/bin/bash
#
# Installs the Claude Code custom scripts from this folder into ~/.claude:
#   1. soft-links each hook script into ~/.claude/hooks/  (repo stays the source of
#      truth, so `git pull` updates the live hook)
#   2. registers the diff-stat Stop hook in ~/.claude/settings.json
#
# Idempotent: a correct existing symlink and an already-registered hook are left
# alone. A real file or wrong symlink at the target is backed up before relinking,
# and settings.json is backed up before any edit. Uses python3 (no jq dependency).

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
hooks_dir="$claude_dir/hooks"
settings="$claude_dir/settings.json"

link_path() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "Already linked: $target"
    return
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up $target -> $backup"
    mv "$target" "$backup"
  fi

  ln -s "$source" "$target"
  echo "Linked $target -> $source"
}

# 1. Soft-link the hook into ~/.claude/hooks/
chmod +x "$repo_dir/diff-stat.sh"
link_path "$repo_dir/diff-stat.sh" "$hooks_dir/diff-stat.sh"

# 2. Register the Stop hook in settings.json (idempotent; backed up first).
python3 - "$settings" "$hooks_dir/diff-stat.sh" <<'PY'
import json, os, sys, datetime

settings_path, hook_cmd = sys.argv[1], sys.argv[2]

if os.path.exists(settings_path):
    with open(settings_path) as f:
        text = f.read()
    data = json.loads(text) if text.strip() else {}
    ts = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    with open(f"{settings_path}.backup.{ts}", "w") as f:
        f.write(text)
else:
    os.makedirs(os.path.dirname(settings_path), exist_ok=True)
    data = {}

stop = data.setdefault("hooks", {}).setdefault("Stop", [])

def already_registered(entries, cmd):
    return any(h.get("command") == cmd
              for e in entries for h in e.get("hooks", []))

if already_registered(stop, hook_cmd):
    print(f"Stop hook already registered: {hook_cmd}")
else:
    stop.append({"hooks": [{"type": "command", "command": hook_cmd, "timeout": 10}]})
    with open(settings_path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    print(f"Registered Stop hook: {hook_cmd}")
PY

echo
echo "Done. Start a new Claude Code session (or open /hooks once) to load the change."
