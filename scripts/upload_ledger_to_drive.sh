#!/bin/bash
# 🌌 Etherverse Ledger Uploader to Google Drive

LEDGER="$HOME/etherverse/docs/self_awareness_ledger.json"
FOLDER_NAME="Etherverse_Ledgers"

echo "[+] Checking for gdrive CLI..."
if ! command -v gdrive &> /dev/null; then
  echo "[⚠️] gdrive not found. Install with:"
  echo "  sudo apt install gdrive"
  exit 1
fi

echo "[+] Locating or creating Drive folder..."
FOLDER_ID=$(gdrive list --query "name='$FOLDER_NAME' and mimeType='application/vnd.google-apps.folder'" --no-header | awk '{print $1}')
if [ -z "$FOLDER_ID" ]; then
  FOLDER_ID=$(gdrive mkdir "$FOLDER_NAME" | awk '{print $2}')
  echo "[+] Created Drive folder with ID: $FOLDER_ID"
else
  echo "[+] Found existing folder with ID: $FOLDER_ID"
fi

echo "[+] Uploading ledger to Drive..."
UPLOAD_ID=$(gdrive update --parent "$FOLDER_ID" "$LEDGER" 2>/dev/null || gdrive upload --parent "$FOLDER_ID" "$LEDGER" | awk 'NR==2{print $2}')

echo "[+] Making file shareable..."
gdrive share "$UPLOAD_ID" --role reader --type anyone >/dev/null

SHARE_URL="https://drive.google.com/uc?id=$UPLOAD_ID&export=download"
echo "✅ Upload complete."
echo "🌐 Public JSON URL:"
echo "$SHARE_URL"

echo "$SHARE_URL" > "$HOME/etherverse/docs/ledger_drive_url.txt"
