#!/bin/bash
# 🌐 Etherverse: Full Ledger Sync (via rclone)
# Syncs all *.json ledgers in ~/etherverse/docs to Google Drive

DOCS_DIR="$HOME/etherverse/docs"
REMOTE_DIR="gdrive:Etherverse/Ledgers"

echo "[+] Starting full ledger sync..."
if [ -d "$DOCS_DIR" ]; then
    find "$DOCS_DIR" -type f -name "*.json" | while read -r file; do
        echo "→ Uploading $(basename "$file") ..."
        rclone copy "$file" "$REMOTE_DIR" --progress
    done
    echo "✅ All ledgers synced to $REMOTE_DIR"
else
    echo "⚠️ Docs directory not found: $DOCS_DIR"
fi
