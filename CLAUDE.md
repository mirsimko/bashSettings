# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal shell/terminal configuration and utility scripts for a WSL2 (Linux on Windows) environment. No build system, no test suite, no package manager.

## Validating Changes

```bash
bash -n <script>          # syntax-check any shell script (required before committing)
shellcheck <script>       # lint (if shellcheck is installed)
```

There are no automated tests. Validate manually by running the affected script with safe arguments.

## Repository Layout

- **Root dotfiles**: `.mybashrc`, `.vimrc`, `.tmux.conf`, `.Xresources`, `.lessfilter` — symlinked into `$HOME` by `setupBashAndVim.sh`
- **Setup scripts** (root level): `setupBashAndVim.sh`, `configureGit.sh`, `configureXterm.sh`, `installAck.sh` — run once to bootstrap a new machine
- **`bin/`**: End-user CLI commands (SSH helpers, file transfer wrappers, VPN, `update_ai_tools.sh`). Added to `$PATH` via `.mybashrc`. New commands go here.
- **`nightly/`**: Scheduled automation scripts invoked by Windows Task Scheduler via `wsl -e`. Each script is symlinked from `~/` so the scheduler can reference `~/script-name.sh`. PowerShell `.ps1` files in the same directory register the scheduled tasks.

## Nightly Agents

The `nightly/` scripts launch Claude Code in headless mode (`claude -p`) with `--dangerously-skip-permissions` and a budget cap. They rely on Docker (for MCP servers) and Edge with remote debugging (for browser automation). Each script:
1. Ensures Docker Desktop and Edge are running
2. `cd`s into the Obsidian vault directory
3. Runs `claude -p` with a detailed prompt
4. Logs to `/tmp/<script-name>-YYYY-MM-DD.log`

| Script | Schedule | Purpose |
|--------|----------|---------|
| `claude-daily.sh` | 6:00 AM daily | Morning agent: weather, calendar, email, LinkedIn, Strava, Codmon check, daily note + Slack summary |
| `claude-codmon.sh` | 4:00 PM weekdays | Extract nursery school records from Codmon (JP site), translate JP→EN, write to vault |
| `qmd-embed.sh` | 3:00 AM daily | Re-index zettelkasten vault and generate QMD vector embeddings |

## Conventions

- All scripts use `#!/bin/bash`
- 2-space indentation
- Quote variable expansions (`"$PWD"`, `"$HOME"`)
- Lowercase script names; `.sh` suffix for scripts run directly
- Keep scripts small and single-purpose
- Commit messages: short, imperative subject line
