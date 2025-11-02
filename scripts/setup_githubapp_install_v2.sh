#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$HOME/etherverse-x-one/scripts/setup_githubapp_install_v2.sh"
cat > "$SCRIPT_PATH" << 'BASH'
#!/usr/bin/env bash
set -euo pipefail

echo "=== GitHub App Setup for Autonomous Agent (v2) ==="
read -r -p "Enter GitHub App Installation ID: " INSTALLATION_ID
read -r -p "Enter full path to GitHub App Private Key (.pem) file: " PRIVATE_KEY_PATH

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
  echo "ERROR: File not found at $PRIVATE_KEY_PATH"
  exit 1
fi

CONFIG_DIR="$HOME/etherverse-x-one/config"
mkdir -p "$CONFIG_DIR"

CONFIG_FILE="$CONFIG_DIR/github_app_config.sh"
cat > "$CONFIG_FILE" << EOF
# GitHub App configuration (auto‑generated)
export GITHUB_APP_ID="2215740"
export GITHUB_APP_INSTALLATION_ID="${INSTALLATION_ID}"
export GITHUB_APP_PRIVATE_KEY_PATH="${PRIVATE_KEY_PATH}"
EOF

chmod 600 "$CONFIG_FILE"
echo "✔ Config saved to: $CONFIG_FILE"

read -r -p "Upload private key to Google Secret Manager? (y/N): " yn
if [[ "$yn" =~ ^[Yy]$ ]]; then
  SECRET_NAME="github-app-private-key"
  echo "Uploading secret ${SECRET_NAME} ..."
  if ! gcloud secrets create ${SECRET_NAME} --data-file="$PRIVATE_KEY_PATH" --project="infinity-x-one-swarm-system"; then
    echo "Secret create failed or already exists. Adding new version..."
    gcloud secrets versions add ${SECRET_NAME} --data-file="$PRIVATE_KEY_PATH" --project="infinity-x-one-swarm-system"
  fi
  echo "Secret uploaded: ${SECRET_NAME}"
fi

echo "Setup complete. To proceed:"
echo "  source \"$CONFIG_FILE\""
echo "Then run your autonomous loop script."
BASH

chmod +x "$SCRIPT_PATH"
echo "Setup script created at: $SCRIPT_PATH"
echo "Opening for review..."
nano "$SCRIPT_PATH"
echo "When ready, run:"
echo "  $SCRIPT_PATH"
