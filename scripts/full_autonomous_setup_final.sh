#!/usr/bin/env bash
set -euo pipefail

echo "🔐 Starting full autonomous GPT + GitHub App + Cloud Run setup..."

APP_ID="2215740"
INSTALLATION_ID="92537509"
APP_NAME="etherverse-x-one"
APP_CLIENT_ID="lv23iIiRvp5scKIkDHZw"
CONFIG_DIR="$HOME/etherverse-x-one/config"
KEY_PATH="$CONFIG_DIR/github_app_private_key.pem"
SECRET_NAME="github-app-private-key"
PROJECT="infinity-x-one-swarm-system"
SERVICE_ACCOUNT="gpt-autonomous@$PROJECT.iam.gserviceaccount.com"

# 🔑 Embedded GitHub App Private Key
mkdir -p "$CONFIG_DIR"
cat <<EOF > "$KEY_PATH"
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAnKxqNWtiipu30hrYuli7Va0O8fVgJpNd...
[REMAINDER OF KEY]
-----END RSA PRIVATE KEY-----
EOF

chmod 600 "$KEY_PATH"
echo "✅ Private key written to $KEY_PATH"

# ☁️ Upload to Secret Manager
echo "🔄 Uploading key to Google Secret Manager..."
echo "Creating secret [$SECRET_NAME] in [$PROJECT]..."
gcloud secrets create "$SECRET_NAME" \
  --data-file="$KEY_PATH" \
  --replication-policy="automatic" \
  --project="$PROJECT" || echo "Secret may already exist."

gcloud secrets versions add "$SECRET_NAME" \
  --data-file="$KEY_PATH" \
  --project="$PROJECT"

# 💾 Save config
cat <<EOF > "$CONFIG_DIR/github_app_config.sh"
export GITHUB_APP_ID="$APP_ID"
export GITHUB_INSTALLATION_ID="$INSTALLATION_ID"
export GITHUB_APP_NAME="$APP_NAME"
export GITHUB_CLIENT_ID="$APP_CLIENT_ID"
export GITHUB_PRIVATE_KEY_PATH="$KEY_PATH"
EOF

echo "✅ Config written to $CONFIG_DIR/github_app_config.sh"
echo "➡️  Run this to load it now:"
echo "    source $CONFIG_DIR/github_app_config.sh"

# ⚡ Launch autonomous GPT loop
echo "🚀 Launching autonomous GPT orchestration loop..."
bash ~/etherverse-x-one/scripts/github_app_autonomous_loop.sh || echo "➡️ Loop script missing? Add it next."

echo "🧠 System wired. Press Enter to finish."
read _
