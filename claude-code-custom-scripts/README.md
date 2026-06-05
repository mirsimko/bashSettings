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

## Install

```bash
./install.sh
```

This soft-links `diff-stat.sh` into `~/.claude/hooks/` (so `git pull` updates the live
hook) and registers the `Stop` hook in `~/.claude/settings.json`. It is idempotent and
backs up anything it replaces. Set `CLAUDE_CONFIG_DIR` to target a non-default config
dir. Start a new Claude Code session (or open `/hooks` once) afterwards to load it.
