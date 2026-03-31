#!/usr/bin/env bash
set -uo pipefail

export QMD_EMBED_MODEL="hf:Qwen/Qwen3-Embedding-0.6B-GGUF/Qwen3-Embedding-0.6B-Q8_0.gguf"

NTFY_URL="http://192.168.0.14/claude-agents"
LOG="/tmp/qmd-embed-$(date +%Y-%m-%d).log"
exec &> >(tee -a "$LOG")
echo "=== QMD embed started at $(date) ==="

notify_failure() {
  curl -sf -m 5 \
    -H "Title: QMD Embed Failed" \
    -H "Priority: high" \
    -H "Tags: warning" \
    -d "$1" \
    "$NTFY_URL" 2>/dev/null || true
}

if ! /usr/bin/qmd update; then
  notify_failure "qmd update failed at $(date). Check log: $LOG"
  exit 1
fi

if ! /usr/bin/qmd embed; then
  notify_failure "qmd embed failed at $(date). Check log: $LOG"
  exit 1
fi

echo "=== QMD embed finished at $(date) ==="
