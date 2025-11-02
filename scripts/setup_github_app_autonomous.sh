#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$HOME/etherverse-x-one/config"
mkdir -p "$CONFIG_DIR"

echo "Enter GitHub App Installation ID:"
read -r INSTALLATION_ID
echo "Enter full path to GitHub App private key (.pem):"
read -r PRIVATE_KEY_PATH

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
  echo "ERROR: file not found: $PRIVATE_KEY_PATH"
  exit 1
fi

cat > "$CONFIG_DIR/github_app_config.sh" << EOF
export GITHUB_APP_ID="2215740"
export GITHUB_APP_INSTALLATION_ID="${INSTALLATION_ID}"
export GITHUB_APP_PRIVATE_KEY_PATH="${PRIVATE_KEY_PATH}"
EOF

chmod 600 "$CONFIG_DIR/github_app_config.sh"
echo "Config written to $CONFIG_DIR/github_app_config.sh"

read -r -p "Upload private key to Google Secret Manager? (y/N): " yn
if [[ "$yn" =~ ^[Yy]$ ]]; then
  SECRET_NAME="github-app-private-key"
  gcloud secrets create ${SECRET_NAME} --data-file="$PRIVATE_KEY_PATH" --project="infinity-x-one-swarm-system" || \
    gcloud secrets versions add ${SECRET_NAME} --data-file="$PRIVATE_KEY_PATH" --project="infinity-x-one-swarm-system"
  echo "Secret uploaded: $SECRET_NAME"
fi

echo "✔ Setup complete. Then run:"
echo "  source $CONFIG_DIR/github_app_config.sh"
echo "Then invoke your autonomous agent loop."
