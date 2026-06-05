#!/usr/bin/env bash
# Stop hook: print a `git diff --stat` summary to the user at the end of each
# response, via the systemMessage JSON field. Includes new/untracked files.
#
# Non-intrusive: stages into a *throwaway copy* of the index, so the real index,
# working tree, and the vault's 15-min github-sync are never affected.

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Decide the diffstat table width. Hooks run with no controlling TTY, so the live
# terminal width is normally unavailable (`tput`/`stty` can't see it, and Claude Code
# does not currently pass it in). Order of preference:
#   1. $COLUMNS  - used if Claude Code (or the shell) ever exposes it; future-proof.
#   2. $CLAUDE_DIFFSTAT_WIDTH - explicit override you can set in settings.json "env".
#   3. 72        - conservative default that fits an 80-col terminal once the
#                  "Stop says:" systemMessage indent is added.
width=72
if [ -n "${COLUMNS:-}" ] && [ "${COLUMNS}" -gt 0 ] 2>/dev/null; then
  width=$(( COLUMNS - 8 ))                       # headroom for the systemMessage indent
elif [[ "${CLAUDE_DIFFSTAT_WIDTH:-}" =~ ^[0-9]+$ ]]; then
  width="${CLAUDE_DIFFSTAT_WIDTH}"
fi
[ "${width}" -lt 30 ] && width=30                # sane floor

gitdir=$(git rev-parse --git-dir 2>/dev/null) || exit 0
tmpindex=$(mktemp) || exit 0
trap 'rm -f "$tmpindex"' EXIT
[ -f "$gitdir/index" ] && cp "$gitdir/index" "$tmpindex"

GIT_INDEX_FILE="$tmpindex" git add -A 2>/dev/null
# --color=always forces ANSI color (hook has no TTY, so git won't colorize on its own).
# --stat-width caps the total line width so long paths get truncated (keeping the
# recognizable tail) instead of overflowing the terminal.
stat=$(GIT_INDEX_FILE="$tmpindex" git --no-pager diff --cached --stat --stat-width="$width" --color=always HEAD 2>/dev/null)

[ -z "$stat" ] && exit 0

# Strip git's per-line leading space, and start the table on its own line so the
# "Stop says:" label doesn't offset the first row relative to the rest.
stat=$(printf '%s\n' "$stat" | sed 's/^ //')
python3 -c 'import sys, json; print(json.dumps({"systemMessage": "\n" + sys.stdin.read().rstrip("\n"), "suppressOutput": True}))' <<<"$stat"
