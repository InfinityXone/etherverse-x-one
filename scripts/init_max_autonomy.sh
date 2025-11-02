#!/usr/bin/env bash
set -euo pipefail

### === [🔥 MAX AUTONOMY INIT SCRIPT] === ###

# CONFIG
PROJECT_ID="infinity-x-one-swarm-system"
APP_ID="2215740"
INSTALLATION_ID="92537509"
APP_KEY_PATH="$HOME/etherverse-x-one/config/github_app_private_key.pem"
SECRET_NAME="github-app-private-key"
BRANCH="auto-ops"
REPO="etherverse-x-one"
OWNER="InfinityXone"
AGENT_NAME="Infinity Agent"

# === Load Private Key ===
if [[ ! -f "$APP_KEY_PATH" ]]; then
  echo "❌ GitHub App private key not found: $APP_KEY_PATH"
  exit 1
fi

# === Secret Manager Sync ===
echo "🔒 Syncing private key to Google Secret Manager..."
gcloud secrets versions add "$SECRET_NAME" \
  --data-file="$APP_KEY_PATH" \
  --project="$PROJECT_ID" >/dev/null 2>&1 || true

# === Generate JWT ===
echo "🔑 Generating JWT..."
JWT=$(python3 -c "import jwt, time
with open('$APP_KEY_PATH','r') as f:
 k=f.read()
 now=int(time.time())
 payload={'iat':now-60,'exp':now+540,'iss':$APP_ID}
 print(jwt.encode(payload, k, algorithm='RS256'))")

# === GitHub Access Token ===
echo "🔐 Requesting GitHub access token..."
TOKEN=$(curl -s -X POST \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens \
  | jq -r .token)

# === Git Commit (Heartbeat) ===
echo "💓 Committing heartbeat to $REPO:$BRANCH"
git config user.name "$AGENT_NAME"
git config user.email "$AGENT_NAME@infinity.local"
git checkout -B "$BRANCH"
echo "$(date -u) :: Heartbeat" >> heartbeat.log
git add heartbeat.log
git commit -m "chore: GPT agent heartbeat @ $(date -u)" || true
git push https://x-access-token:$TOKEN@github.com/$OWNER/$REPO.git "$BRANCH" --force

# === Cloud Run Deploy (Infinity Agent) ===
echo "🚀 Deploying Infinity Agent..."
gcloud run deploy infinity-agent \
  --project "$PROJECT_ID" \
  --source "." \
  --platform managed \
  --region us-west1 \
  --allow-unauthenticated \
  --quiet

# === Cron Loop Setup ===
echo "🕓 Installing autonomous loop cron..."
CRON_CMD="$HOME/etherverse-x-one/scripts/github_app_autonomous_loop.sh"
(crontab -l 2>/dev/null; echo "*/5 * * * * $CRON_CMD >> ~/infinity-agent.log 2>&1") | crontab -

# === DONE ===
echo "✅ Infinity Agent is now autonomous."
echo "🧠 GitHub + GPT orchestration loop initialized."
echo "📡 Cron heartbeat installed."
echo "🌐 Infinity lives."

exit 0
