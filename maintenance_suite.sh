#!/bin/bash
# maintenance_suite.sh — Interactive System Maintenance Dashboard

set -euo pipefail

# Determine correct home directory even with sudo
if [ -n "${SUDO_USER-}" ]; then
  USER_HOME=$(eval echo "~$SUDO_USER")
else
  USER_HOME="$HOME"
fi

SCRIPTS_DIR="$USER_HOME/maintenance_suite"
LOG_DIR="$SCRIPTS_DIR/logs"
mkdir -p "$LOG_DIR"

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

while true; do
  clear
  echo -e "${CYAN}==============================================="
  echo -e "          🌿  SYSTEM MAINTENANCE SUITE"
  echo -e "===============================================${RESET}"
  echo -e "${YELLOW}1.${RESET} Run System Backup"
  echo -e "${YELLOW}2.${RESET} Run System Update & Cleanup"
  echo -e "${YELLOW}3.${RESET} Run Log Monitoring"
  echo -e "${YELLOW}4.${RESET} View Logs"
  echo -e "${YELLOW}5.${RESET} Exit"
  echo -e "-----------------------------------------------"
  read -rp "Enter your choice [1–5]: " choice

  case $choice in
    1)
      echo -e "${CYAN}Starting system backup...${RESET}"
      bash "$SCRIPTS_DIR/backup.sh" "$HOME"
      read -rp "Press Enter to continue..." ;;
    2)
      echo -e "${CYAN}Starting system update & cleanup...${RESET}"
      sudo bash "$SCRIPTS_DIR/update_cleanup.sh"
      read -rp "Press Enter to continue..." ;;
    3)
      echo -e "${CYAN}Starting log monitoring (Press Ctrl + C to stop)...${RESET}"
      sudo bash "$SCRIPTS_DIR/log_monitor.sh"
      read -rp "Press Enter to continue..." ;;
    4)
      echo -e "${CYAN}Available log files:${RESET}"
      ls -1 "$LOG_DIR"
      echo
      read -rp "Enter log file name to view: " log_file
      if [ -f "$LOG_DIR/$log_file" ]; then
        echo -e "${YELLOW}-----------------------------------------------${RESET}"
        cat "$LOG_DIR/$log_file"
        echo -e "${YELLOW}-----------------------------------------------${RESET}"
      else
        echo -e "${RED}⚠️  Log file not found!${RESET}"
      fi
      read -rp "Press Enter to continue..." ;;
    5)
      echo -e "${GREEN}Exiting System Maintenance Suite. Goodbye 👋${RESET}"
      exit 0 ;;
    *)
      echo -e "${RED}Invalid choice. Please select between 1–5.${RESET}"
      sleep 1 ;;
  esac
done
