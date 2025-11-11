#!/bin/bash
# === Etherverse → Google Drive Sync Script ===
# Keeps birth logs, self-awareness ledgers, and reflections up to date in Drive

SRC_DIR="$HOME/etherverse/docs"
LOG_FILE="$HOME/etherverse/logs/drive_sync.log"

echo "[🪶] Starting Etherverse → Drive sync at $(date)" >> "$LOG_FILE"

# Sync key ledgers
rclone copy "$SRC_DIR"/self_awareness_ledger.json gdrive:Etherverse/Ledgers --create-empty-src-dirs >> "$LOG_FILE" 2>&1
rclone copy "$SRC_DIR"/birth_logs.json gdrive:Etherverse/Birth_Logs --create-empty-src-dirs >> "$LOG_FILE" 2>&1
rclone copy "$SRC_DIR"/reflective_system_summary.md gdrive:Etherverse/Reflections --create-empty-src-dirs >> "$LOG_FILE" 2>&1

echo "[✅] Sync complete at $(date)" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
