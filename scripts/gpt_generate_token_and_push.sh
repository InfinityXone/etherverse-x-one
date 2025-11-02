#!/bin/bash

set -e

# === CONFIG ===
APP_ID="2215740"
INSTALLATION_ID="92537509"
PRIVATE_KEY_PATH="$HOME/etherverse-x-one/config/github_app_private_key.pem"
REPO_NAME="etherverse-x-one"
GIT_EMAIL="gpt@etherverse.ai"
GIT_USER="Infinity Agent"
GITHUB_USER="InfinityXone"

# === Get JWT ===
echo "🔐 Generating JWT..."
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

# === Exchange JWT for installation token ===
echo "🔑 Requesting GitHub access token..."
ACCESS_TOKEN=$(curl -s -X POST \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens | jq -r '.token')

if [[ "$ACCESS_TOKEN" == "null" || -z "$ACCESS_TOKEN" ]]; then
    echo "❌ Failed to get access token. Check App ID, private key, or installation ID."
    exit 1
fi

echo "$ACCESS_TOKEN" > /tmp/github_token
echo "✅ GitHub token acquired."

# === Git Setup ===
echo "🔧 Configuring Git identity..."
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_USER"

# === Clone and Push Test ===
echo "📦 Cloning repo..."
WORKDIR="/tmp/$REPO_NAME"
rm -rf "$WORKDIR"
git clone https://x-access-token:$ACCESS_TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git "$WORKDIR"

cd "$WORKDIR"
echo "📄 Writing agent file..."
mkdir -p agents
echo "# 🤖 Hello from GPT Agent" > agents/alpha.py
git add agents/alpha.py
git commit -m "🤖 Add Alpha agent template"

echo "🚀 Pushing with token..."
git push https://x-access-token:$ACCESS_TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git HEAD:main

echo "🎉 Push complete. GPT is now autonomous."
