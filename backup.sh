#!/bin/bash
# backup.sh — Robust automated backup script with safe checks and logging

set -o pipefail
trap 'echo "[ERROR] Script failed at line $LINENO"; exit 1' ERR

# Use the HOME path passed as an argument, or default to current user's home
USER_HOME="${1:-$HOME}"

BACKUP_SRC="$USER_HOME/Documents"
BACKUP_DEST="$USER_HOME/system_backups"
LOG_DIR="$USER_HOME/maintenance_suite/logs"
LOG_FILE="$LOG_DIR/backup.log"

# Ensure destination and log directories exist
mkdir -p "$BACKUP_DEST"
mkdir -p "$(dirname "$LOG_FILE")"

# Create filename with timestamp
FILENAME="backup_$(date +%Y%m%d_%H%M%S).tar.gz"

# Start logging
echo "[$(date)] Starting backup..." | tee -a "$LOG_FILE"

# Perform backup
tar -czf "$BACKUP_DEST/$FILENAME" "$BACKUP_SRC" >>"$LOG_FILE" 2>&1

# Check result
if [ $? -eq 0 ]; then
    echo "[$(date)] ✅ Backup completed successfully: $FILENAME" | tee -a "$LOG_FILE"
else
    echo "[$(date)] ❌ Backup failed!" | tee -a "$LOG_FILE"
fi
