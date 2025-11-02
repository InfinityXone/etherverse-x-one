#!/usr/bin/env bash
set -euo pipefail

APP_ID="2215740"
INSTALLATION_ID="92537509"
PROJECT="infinity-x-one-swarm-system"
CONFIG_DIR="$HOME/etherverse-x-one/config"
KEY_PATH="$HOME/etherverse-x-one/secrets/your_private_key.pem"  # ← replace this with full path to your .pem file

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/github_app_config.sh" << EOF
export GITHUB_APP_ID="$APP_ID"
export GITHUB_APP_INSTALLATION_ID="$INSTALLATION_ID"
export GITHUB_APP_PRIVATE_KEY_PATH="$KEY_PATH"
EOF

chmod 600 "$CONFIG_DIR/github_app_config.sh"
echo "Config written to $CONFIG_DIR/github_app_config.sh"

echo "Now source it with:"
echo "  source $CONFIG_DIR/github_app_config.sh"

read -p "Press Enter when you are ready to launch autonomous loop…" _
