#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/home/miro/zettelkasten"
LOG_FILE="/tmp/zettelkasten-embed-$(date +%Y-%m-%d).log"
QMD="/home/miro/.npm-global/bin/qmd"
NTFY_URL="http://localhost/zettelkasten-embed"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

notify_failure() {
    log "$1"
    curl -s -H "Title: zettelkasten-embed failed" -H "Priority: high" -H "Tags: x" -d "$1" "$NTFY_URL" > /dev/null 2>&1
}

log "=== Starting zettelkasten embed job ==="

# Step 1: git pull
log "STEP 1: git pull"
cd "$REPO_DIR"
if git pull origin main >> "$LOG_FILE" 2>&1; then
    log "STEP 1: git pull succeeded"
else
    notify_failure "STEP 1: FAILED - git pull failed (exit code $?)"
    exit 1
fi
#
# Step 3: qmd update
log "STEP 2: qmd eupdate"
if "$QMD" update >> "$LOG_FILE" 2>&1; then
    log "STEP 2: qmd update succeeded"
else
    notify_failure "STEP 2: FAILED - qmd update failed (exit code $?)"
    exit 2
fi


# Step 3: qmd embed
log "STEP 3: qmd embed"
if "$QMD" embed >> "$LOG_FILE" 2>&1; then
    log "STEP 3: qmd embed succeeded"
else
    notify_failure "STEP 3: FAILED - qmd embed failed (exit code $?)"
    exit 3
fi

log "=== Zettelkasten embed job completed successfully ==="
