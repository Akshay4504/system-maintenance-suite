#!/bin/bash
# update_cleanup.sh — System update and cleanup script (final robust version)

set -euo pipefail
trap 'echo "[ERROR] Script failed at line $LINENO"; exit 1' ERR

# Determine the correct home directory even if run with sudo
if [ -n "${SUDO_USER-}" ]; then
  USER_HOME=$(eval echo "~$SUDO_USER")
else
  USER_HOME="$HOME"
fi

LOG_DIR="$USER_HOME/maintenance_suite/logs"
LOG_FILE="$LOG_DIR/update_cleanup.log"

mkdir -p "$LOG_DIR"
chown "${SUDO_USER:-$USER}" "$LOG_DIR" 2>/dev/null || true

echo "[$(date)] Starting system update and cleanup..." | tee -a "$LOG_FILE"

# Run apt commands in non-interactive mode to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Function to safely run apt commands without aborting on warnings
run_apt() {
    echo "[INFO] Running: $*" | tee -a "$LOG_FILE"
    if ! "$@" >>"$LOG_FILE" 2>&1; then
        echo "[WARN] Command '$*' returned a non-zero exit code. Continuing..." | tee -a "$LOG_FILE"
    fi
}

# Update & cleanup sequence
run_apt sudo apt-get update -y
run_apt sudo apt-get upgrade -y -o Dpkg::Options::="--force-confold"
run_apt sudo apt-get dist-upgrade -y
run_apt sudo apt-get autoremove -y
run_apt sudo apt-get autoclean -y

echo "[$(date)] ✅ System update and cleanup completed successfully!" | tee -a "$LOG_FILE"
