#!/bin/bash
# log_monitor.sh — Real-time log monitoring script

set -euo pipefail
trap 'echo "[ERROR] Script failed at line $LINENO"; exit 1' ERR

# Detect proper home even when using sudo
if [ -n "${SUDO_USER-}" ]; then
  USER_HOME=$(eval echo "~$SUDO_USER")
else
  USER_HOME="$HOME"
fi

LOG_DIR="$USER_HOME/maintenance_suite/logs"
MONITOR_LOG="$LOG_DIR/log_monitor.log"

mkdir -p "$LOG_DIR"
chown "${SUDO_USER:-$USER}" "$LOG_DIR" 2>/dev/null || true

echo "[$(date)] Starting log monitoring..." | tee -a "$MONITOR_LOG"

# Check if there are any .log files to monitor
LOG_FILES=("$LOG_DIR"/*.log)
if [ ! -e "${LOG_FILES[0]}" ]; then
  echo "[$(date)] ⚠️ No log files found in $LOG_DIR to monitor." | tee -a "$MONITOR_LOG"
  exit 0
fi

# Tail and monitor logs for errors and warnings
tail -Fn0 "${LOG_FILES[@]}" | \
while read -r line; do
  if echo "$line" | grep -Eiq "error|failed|warn|permission denied"; then
    echo "[$(date)] ⚠️ Alert: $line" | tee -a "$MONITOR_LOG"
  fi
done
