#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/home/miro/zettelkasten"
LOG_FILE="/tmp/zettelkasten-embed-$(date +%Y-%m-%d).log"
QMD="/home/miro/.npm-global/bin/qmd"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Starting zettelkasten embed job ==="

# Step 1: git pull
log "STEP 1: git pull"
cd "$REPO_DIR"
if git pull origin main >> "$LOG_FILE" 2>&1; then
    log "STEP 1: git pull succeeded"
else
    log "STEP 1: FAILED - git pull failed (exit code $?)"
    exit 1
fi

# Step 2: qmd embed
log "STEP 2: qmd embed"
if "$QMD" embed >> "$LOG_FILE" 2>&1; then
    log "STEP 2: qmd embed succeeded"
else
    log "STEP 2: FAILED - qmd embed failed (exit code $?)"
    exit 2
fi

log "=== Zettelkasten embed job completed successfully ==="
