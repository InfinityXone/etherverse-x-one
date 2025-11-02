#!/usr/bin/env bash
set -e

echo "🔐 Finalizing GitHub App private key setup..."

KEY_SRC="$HOME/Downloads/etherverse-x-one.2025-11-01.private-key.pem"
KEY_DEST="$HOME/etherverse-x-one/config/github_app_private_key.pem"

if [[ ! -f "$KEY_SRC" ]]; then
  echo "❌ Private key not found at: $KEY_SRC"
  exit 1
fi

mkdir -p "$(dirname "$KEY_DEST")"
cp "$KEY_SRC" "$KEY_DEST"
chmod 600 "$KEY_DEST"
echo "✅ Key copied to: $KEY_DEST"

echo "🔄 Uploading key to Secret Manager: github-app-private-key"
gcloud secrets create github-app-private-key --replication-policy="automatic" --data-file="$KEY_DEST" --project="infinity-x-one-swarm-system" || true
gcloud secrets versions add github-app-private-key --data-file="$KEY_DEST" --project="infinity-x-one-swarm-system"

echo "✅ Key ready. Launching autonomous orchestration loop..."
bash "$HOME/etherverse-x-one/scripts/github_app_autonomous_loop.sh"
