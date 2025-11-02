#!/usr/bin/env bash
set -euo pipefail

echo "🔐 Finalizing Autonomous GPT + GitHub App Setup..."

# === CONFIG ===
PROJECT_ID="infinity-x-one-swarm-system"
APP_ID="2215740"
INSTALLATION_ID="92537509"
PRIVATE_KEY_PATH="$HOME/etherverse-x-one/config/github_app_private_key.pem"
SECRET_NAME="github-app-private-key"
REPO_NAME="etherverse-x-one"
AGENT_NAME="Infinity Agent"
AGENT_ROLE="Infinity Agent"
IPC_SOCKET_PATH="/tmp/agent_one.sock"

# === STEP 1: Ensure key exists ===
if [[ ! -f "$PRIVATE_KEY_PATH" ]]; then
  echo "❌ ERROR: Private key not found at $PRIVATE_KEY_PATH"
  exit 1
fi

# === STEP 2: Upload to Google Secret Manager ===
echo "🔄 Uploading key to Secret Manager: $SECRET_NAME"
if gcloud secrets describe "$SECRET_NAME" --project="$PROJECT_ID" &>/dev/null; then
  gcloud secrets versions add "$SECRET_NAME" \
    --data-file="$PRIVATE_KEY_PATH" \
    --project="$PROJECT_ID"
else
  gcloud secrets create "$SECRET_NAME" \
    --replication-policy="automatic" \
    --data-file="$PRIVATE_KEY_PATH" \
    --project="$PROJECT_ID"
fi

# === STEP 3: Generate JWT ===
echo "🔑 Generating JWT..."
JWT=$(python3 - <<EOF
import jwt, time
with open("$PRIVATE_KEY_PATH", "r") as f:
    private_key = f.read()
payload = {
    "iat": int(time.time()) - 60,
    "exp": int(time.time()) + (10 * 60),
    "iss": "$APP_ID"
}
encoded = jwt.encode(payload, private_key, algorithm="RS256")
print(encoded)
EOF
)

# === STEP 4: Exchange JWT for Access Token ===
echo "🔑 Exchanging JWT for token..."
ACCESS_TOKEN=$(curl -s -X POST \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens" | jq -r '.token')

if [[ "$ACCESS_TOKEN" == "null" ]]; then
  echo "❌ Failed to acquire GitHub token."
  exit 1
fi

echo "✅ GitHub token acquired."

# === STEP 5: Trigger agent loop (mock for now) ===
echo "🧠 Agent is now authenticated and autonomous."
echo "🌐 Ready to access repos, push, deploy, trigger GPT orchestration..."
echo "\"$REPO_NAME\""
echo "🔄 [Heartbeat] GPT Agent Loop running..."
