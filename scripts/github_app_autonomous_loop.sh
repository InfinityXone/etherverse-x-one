#!/usr/bin/env bash
set -euo pipefail

echo "🔁 [AUTONOMOUS LOOP INITIATED]"

CONFIG="$HOME/etherverse-x-one/config/github_app_config.sh"
source "$CONFIG"

echo "[INFO] Generating JWT for GitHub App..."
JWT=$(
  python3 -c "
import jwt, time
with open('$GITHUB_PRIVATE_KEY_PATH', 'r') as f:
    key = f.read()
payload = {
  'iat': int(time.time()) - 60,
  'exp': int(time.time()) + (10 * 60),
  'iss': '$GITHUB_APP_ID'
}
print(jwt.encode(payload, key, algorithm='RS256'))
  "
)

echo "🔑 JWT generated. Exchanging for access token..."

TOKEN_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/app/installations/$GITHUB_INSTALLATION_ID/access_tokens)

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r .token)

if [[ "$ACCESS_TOKEN" == "null" || -z "$ACCESS_TOKEN" ]]; then
  echo "❌ Failed to fetch installation token. Check ID/key."
  exit 1
fi

echo "✅ GitHub token acquired."

# ✅ Autonomous Behavior Placeholder — Expand as needed
echo "🧠 Agent is now authenticated and autonomous."
echo "🌐 Ready to access repos, push, deploy, trigger GPT orchestration..."

# === EXAMPLE ACTION ===
REPO="InfinityXone/etherverse-x-one"
curl -s -H "Authorization: token $ACCESS_TOKEN" \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/repos/$REPO | jq .name

# === LOOP POINT ===
while true; do
  echo "🔄 [Heartbeat] GPT Agent Loop running..."
  sleep 60
done
