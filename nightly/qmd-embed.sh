#!/usr/bin/env bash
set -euo pipefail

LOG="/tmp/qmd-embed-$(date +%Y-%m-%d).log"
exec &> >(tee -a "$LOG")
echo "=== QMD embed started at $(date) ==="

/usr/bin/qmd update
/usr/bin/qmd embed

echo "=== QMD embed finished at $(date) ==="
