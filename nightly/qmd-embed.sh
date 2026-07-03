#!/usr/bin/env bash
set -uo pipefail

export QMD_EMBED_MODEL="hf:Qwen/Qwen3-Embedding-0.6B-GGUF/Qwen3-Embedding-0.6B-Q8_0.gguf"

NTFY_URL="http://192.168.0.14/claude-agents"
LOG="/tmp/qmd-embed-$(date +%Y-%m-%d).log"
CACHE_DIR="/home/miro/.cache/qmd"
INDEX="$CACHE_DIR/index.sqlite"
STATUS_FILE="$CACHE_DIR/embed-status.json"
XPS_HOST="xps13"
XPS_CACHE_DIR="/home/miro/.cache/qmd"
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=15)
exec &> >(tee -a "$LOG")
echo "=== QMD embed started at $(date) ==="
STARTED_AT=$(date -Is)

notify_failure() {
  curl -sf -m 5 \
    -H "Title: QMD Embed Failed" \
    -H "Priority: high" \
    -H "Tags: warning" \
    -d "$1" \
    "$NTFY_URL" 2>/dev/null || true
}

# Writes the status artifact locally and best-effort copies it to xps13,
# so the morning check there sees failures too, not just successes.
write_status() {
  local status="$1" detail="$2"
  local docs vectors index_bytes index_sha
  read -r docs vectors < <(python3 - "$INDEX" <<'PY' 2>/dev/null || echo "0 0"
import sqlite3, sys
con = sqlite3.connect(sys.argv[1])
docs = con.execute("SELECT COUNT(*) FROM documents WHERE active=1").fetchone()[0]
vecs = con.execute("SELECT COUNT(*) FROM content_vectors").fetchone()[0]
print(docs, vecs)
PY
)
  index_bytes=$(stat -c%s "$INDEX" 2>/dev/null || echo 0)
  index_sha=$(sha256sum "$INDEX" 2>/dev/null | cut -d' ' -f1)
  cat > "$STATUS_FILE" <<EOF
{
  "run_date": "$(date +%Y-%m-%d)",
  "started_at": "$STARTED_AT",
  "finished_at": "$(date -Is)",
  "source_host": "$(hostname)",
  "qmd_version": "$(/usr/bin/qmd --version 2>/dev/null | awk '{print $2}')",
  "docs_active": $docs,
  "vectors": $vectors,
  "index_bytes": $index_bytes,
  "index_sha256": "$index_sha",
  "status": "$status",
  "detail": "$detail"
}
EOF
  scp "${SSH_OPTS[@]}" -q "$STATUS_FILE" "$XPS_HOST:$XPS_CACHE_DIR/embed-status.json" 2>/dev/null || true
}

if ! /usr/bin/qmd update; then
  write_status "failed" "qmd update failed"
  notify_failure "qmd update failed at $(date). Check log: $LOG"
  exit 1
fi

EMBED_OUTPUT=$(/usr/bin/qmd embed 2>&1) || {
  echo "$EMBED_OUTPUT"
  write_status "failed" "qmd embed failed"
  notify_failure "qmd embed failed at $(date). Check log: $LOG"
  exit 1
}
echo "$EMBED_OUTPUT"

# qmd embed exits 0 even when individual chunks fail
FAILED_CHUNKS=$(echo "$EMBED_OUTPUT" | grep -oP '\d+ chunks? failed' || true)
if [[ -n "$FAILED_CHUNKS" ]]; then
  write_status "partial" "qmd embed completed but $FAILED_CHUNKS"
  notify_failure "qmd embed partial failure at $(date): $FAILED_CHUNKS. Check log: $LOG"
  exit 1
fi

# Flush the WAL so index.sqlite alone is the complete, current database
python3 - "$INDEX" <<'PY'
import sqlite3, sys
con = sqlite3.connect(sys.argv[1])
con.execute("PRAGMA wal_checkpoint(TRUNCATE)")
con.close()
PY

echo "--- syncing index to $XPS_HOST ---"
if ! rsync -e "ssh ${SSH_OPTS[*]}" --partial "$INDEX" "$XPS_HOST:$XPS_CACHE_DIR/index.sqlite.new"; then
  write_status "failed" "rsync of index.sqlite to $XPS_HOST failed"
  notify_failure "QMD index sync to $XPS_HOST failed (rsync) at $(date). Check log: $LOG"
  exit 1
fi

# Atomic swap on xps13; stale -wal/-shm must not survive next to the new db
if ! ssh "${SSH_OPTS[@]}" "$XPS_HOST" "rm -f $XPS_CACHE_DIR/index.sqlite-wal $XPS_CACHE_DIR/index.sqlite-shm && mv -f $XPS_CACHE_DIR/index.sqlite.new $XPS_CACHE_DIR/index.sqlite"; then
  write_status "failed" "remote swap of index.sqlite on $XPS_HOST failed"
  notify_failure "QMD index swap on $XPS_HOST failed at $(date). Check log: $LOG"
  exit 1
fi

# Verify the copy is a healthy sqlite db without loading any models on xps13
REMOTE_CHECK=$(ssh "${SSH_OPTS[@]}" "$XPS_HOST" "python3 - $XPS_CACHE_DIR/index.sqlite" <<'PY'
import sqlite3, sys
con = sqlite3.connect(sys.argv[1])
ok = con.execute("PRAGMA quick_check").fetchone()[0]
docs = con.execute("SELECT COUNT(*) FROM documents WHERE active=1").fetchone()[0]
print(f"{ok} {docs}")
PY
) || REMOTE_CHECK="check-failed"
echo "remote check: $REMOTE_CHECK"
if [[ "$REMOTE_CHECK" != ok\ * ]]; then
  write_status "failed" "remote integrity check on $XPS_HOST returned: $REMOTE_CHECK"
  notify_failure "QMD index on $XPS_HOST failed integrity check at $(date): $REMOTE_CHECK"
  exit 1
fi

write_status "ok" "index synced to $XPS_HOST, remote check: $REMOTE_CHECK"
echo "=== QMD embed finished at $(date) ==="
