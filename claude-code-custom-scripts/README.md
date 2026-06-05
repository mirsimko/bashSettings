# claude-code-custom-scripts

Custom scripts for [Claude Code](https://claude.com/claude-code), installed into
`~/.claude/`.

## diff-stat.sh

A `Stop` hook that prints a coloured `git diff --stat` summary of the working tree
at the end of every response — a lightweight, Codex-style "changed files" panel.

- Includes new/untracked files by staging into a **throwaway copy** of the index, so
  the real index, working tree, and the vault's 15-min github-sync are never touched.
- Emits the table through the hook's `systemMessage` field (the only user-visible
  channel a `Stop` hook has), with `--color=always` so the `+`/`-` render green/red.
- Caps the table width so long paths truncate (keeping the recognisable tail) instead
  of wrapping. Width is chosen in this order:
  1. `$COLUMNS` if the environment exposes it (future-proof — hooks currently run
     without a TTY, so Claude Code does not pass the live width yet);
  2. `$CLAUDE_DIFFSTAT_WIDTH` — an explicit override you can set in settings `env`;
  3. `72` — a conservative default that fits an 80-column terminal.

## statusline-command.sh

The bottom status bar, rendered as a single coloured line:

```
ctx: 4% (41k/1000k)  |  Opus 4.8 (1M context)  |  owner.name  |  branch  |  5h: 15% (→12:50)  |  wk: 4% (→Sat 04:00)
```

- Reads the `statusLine` JSON Claude Code pipes in on stdin; parses it with `python3`.
- `ctx` shows used context as a percentage and `usedk/sizek`, coloured green/yellow/red
  by how full the window is.
- The project label is `owner.name` from the workspace repo info, falling back to the
  `git remote origin` owner/name, then to the working-directory basename. The git
  branch is appended after it.
- `5h` / `wk` show the Pro/Max rate-limit windows with their reset times; they only
  appear once the first API response has reported them.

## Install

```bash
./install.sh            # diff-stat Stop hook
./install-statusline.sh # statusline
```

`install.sh` soft-links `diff-stat.sh` into `~/.claude/hooks/` and registers the `Stop`
hook in `~/.claude/settings.json`.

`install-statusline.sh` soft-links `statusline-command.sh` into `~/.claude/` and registers
the `statusLine` key in `~/.claude/settings.json`.

Both soft-link from this repo (so `git pull` updates the live script), are idempotent, and
back up anything they replace. Set `CLAUDE_CONFIG_DIR` to target a non-default config dir.
Start a new Claude Code session afterwards to load the change.
