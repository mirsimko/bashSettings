#!/bin/bash
#
# Installs the Claude Code statusline from this folder into ~/.claude:
#   1. soft-links statusline-command.sh into ~/.claude/  (repo stays the source of
#      truth, so `git pull` updates the live statusline)
#   2. registers the statusLine key in ~/.claude/settings.json
#
# Idempotent: a correct existing symlink and an already-matching statusLine command
# are left alone. A real file or wrong symlink at the target is backed up before
# relinking, and settings.json is backed up before any edit. Uses python3 (no jq
# dependency).

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
settings="$claude_dir/settings.json"
target="$claude_dir/statusline-command.sh"

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

# 1. Soft-link the statusline script into ~/.claude/
chmod +x "$repo_dir/statusline-command.sh"
link_path "$repo_dir/statusline-command.sh" "$target"

# 2. Register the statusLine command in settings.json (idempotent; backed up first).
python3 - "$settings" "$target" <<'PY'
import json, os, sys, datetime

settings_path, script_path = sys.argv[1], sys.argv[2]
command = f"bash {script_path}"

if os.path.exists(settings_path):
    with open(settings_path) as f:
        text = f.read()
    data = json.loads(text) if text.strip() else {}
else:
    os.makedirs(os.path.dirname(settings_path), exist_ok=True)
    data = {}

current = data.get("statusLine")
if isinstance(current, dict) and current.get("command") == command \
        and current.get("type") == "command":
    print(f"statusLine already registered: {command}")
else:
    if os.path.exists(settings_path):
        ts = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        with open(f"{settings_path}.backup.{ts}", "w") as f:
            f.write(text)
    data["statusLine"] = {"type": "command", "command": command}
    with open(settings_path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    print(f"Registered statusLine: {command}")
PY

echo
echo "Done. Start a new Claude Code session to load the statusline."
