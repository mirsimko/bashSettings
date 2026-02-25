# Repository Guidelines

## Project Structure & Module Organization

This repository stores personal shell and terminal configuration plus utility scripts.

- Root dotfiles/config: `.mybashrc`, `.vimrc`, `.tmux.conf`, `.Xresources`, `.lessfilter`
- Setup helpers: `setupBashAndVim.sh`, `configureXterm.sh`, `configureGit.sh`, `installAck.sh`
- Utility commands: `bin/` (SSH helpers, file transfer wrappers, image tools, VPN helpers, etc.)
- Documentation: `README.md`

Keep new end-user commands in `bin/` and root-level scripts only for setup/configuration tasks.

## Build, Test, and Development Commands

There is no build system. Use shell checks and manual validation.

- `bash -n setupBashAndVim.sh` : syntax-check a script
- `bash -n bin/<script>` : syntax-check a `bin/` command
- `shellcheck bin/<script>` : lint shell scripts (if `shellcheck` is installed)
- `./configureXterm.sh` : symlink `.Xresources` and reload `xrdb`
- `./setupBashAndVim.sh` : link shell/vim config into `$HOME` and run Vim setup

Run scripts from the repository root when they depend on relative paths.

## Coding Style & Naming Conventions

- Language: Bash (`#!/bin/bash`) for scripts
- Indentation: 2 spaces inside conditionals/loops
- Prefer lowercase script names; use `.sh` suffix for setup/utility scripts that are intended to be run directly
- Keep scripts small and task-focused; add a short comment only when behavior is not obvious
- Prefer quoting variable expansions (`"$PWD"`, `"$HOME"`) and using explicit commands over aliases in scripts

## Testing Guidelines

No automated test suite is present. Validate changes with:

- `bash -n` (required for edited shell scripts)
- `shellcheck` when available
- Manual smoke test of the affected command (for example, run a modified `bin/` helper with safe arguments or `--help` if supported)

Document any manual verification steps in the PR description.

## Commit & Pull Request Guidelines

Git history uses short, imperative summaries (for example: `Script to update all the npm coding-agent tools at once`, `small changes`).

- Use a concise subject line describing the behavior change
- Keep commits focused (one script or one related config change per commit)
- PRs should include: purpose, files changed, manual test steps, and any machine-specific assumptions (hostnames, paths, accounts)
- Include screenshots only for terminal/UI appearance changes (for example, xterm color or prompt tweaks)
