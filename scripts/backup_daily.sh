#!/usr/bin/env bash
# 🧠 Etherverse Daily Backup
SRC="$HOME/etherverse/etherverse"
DEST="$HOME/etherverse/backups"
DATE=$(date +%Y-%m-%d_%H-%M)
mkdir -p "$DEST"
tar -czf "$DEST/etherverse_backup_$DATE.tar.gz" "$SRC" >/dev/null 2>&1
find "$DEST" -type f -mtime +7 -delete
