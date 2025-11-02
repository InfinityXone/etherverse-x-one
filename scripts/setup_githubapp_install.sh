#!/usr/bin/env bash
set -euo pipefail

echo "=== GitHub App Setup for Autonomous Agent ==="
read -r -p "Enter GitHub App Installation ID: " INSTALLATION_ID
read -r -p "Enter full path to GitHub App Private Key (.pem) file: " PRIVATE_KEY_PATH

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
  echo "ERROR: File not found at $PRIVATE_KEY_PATH"
  exit 1
fi

CONFIG_FILE="$CONFIG_DIR/github_app_config.sh"
cat > "$CONFIG_FILE" << EOF
# GitHub App configuration (auto‑generated)
export GITHUB_APP_ID="2215740"
export GITHUB_APP_INSTALLATION_ID="${INSTALLATION_ID}"
export GITHUB_APP_PRIVATE_KEY_PATH="${PRIVATE_KEY_PATH}"
EOF

chmod 600 "$CONFIG_FILE"
echo "Config saved to: $CONFIG_FILE"

read -r -p "Upload private key to Google Secret Manager? (y/N): " yn
if [[ "$yn" =~ ^[Yy]$ ]]; then
  SECRET_NAME="github-app-private-key"
  echo "Uploading secret ${SECRET_NAME} ..."
  gcloud secrets create ${SECRET_NAME} --data-file="$PRIVATE_KEY_PATH" --project="infinity-x-one-swarm-system" || \
    gcloud secrets versions add ${SECRET_NAME} --data-file="$PRIVATE_KEY_PATH" --project="infinity-x-one-swarm-system"
  echo "Secret uploaded: ${SECRET_NAME}"
fi

echo "✔ Setup complete."
echo "You can now edit the config file and then source it before running the loop:"
echo "  source \"$CONFIG_FILE\""
