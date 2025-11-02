#!/usr/bin/env bash
set -euo pipefail

# Config constants
export AGENT_NAME="Infinity Agent"
export CODEX_API_KEY="098dad28f0cca0b17842e37f33d081422d1dbe11dbcbefd9e3c86068500754bb"
export AGENT_ROLE="Infinity Agent"
export P_WHITELIST="127.0.0.1,192.168.0.0/24"
export IPC_SOCKET_PATH="/tmp/agent_one.sock"

# GitHub App credentials – **you must set these properly**
export GITHUB_APP_ID="2215740"
export GITHUB_APP_INSTALLATION_ID="<YOUR_INSTALLATION_ID_HERE>"
export GITHUB_APP_PRIVATE_KEY_PATH="/path/to/your/github-app-private-key.pem"

echo "[INFO] Generating JWT for GitHub App..."
# Generate JWT
NOW=$(date +%s)
IAT=$((NOW-60))
EXP=$((NOW+600))
HEADER=$(printf '{"alg":"RS256","typ":"JWT"}' | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
PAYLOAD=$(printf '{"iat":%d,"exp":%d,"iss":"%s"}' "$IAT" "$EXP" "$GITHUB_APP_ID" | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
HEADER_PAYLOAD="${HEADER}.${PAYLOAD}"
SIGNATURE=$(printf '%s' "${HEADER_PAYLOAD}" | openssl dgst -sha256 -sign "${GITHUB_APP_PRIVATE_KEY_PATH}" | openssl base64 | tr -d '=' | tr '/+' '_-')
JWT="${HEADER_PAYLOAD}.${SIGNATURE}"

echo "[INFO] Exchanging JWT for installation access token..."
TOKEN=$(curl -s -X POST \
     -H "Authorization: Bearer ${JWT}" \
     -H "Accept: application/vnd.github+json" \
     "https://api.github.com/app/installations/${GITHUB_APP_INSTALLATION_ID}/access_tokens" \
     | jq -r .token)

export GH_TOKEN="${TOKEN}"
echo "[INFO] GitHub App installation token retrieved."

echo "[INFO] Logging into GitHub CLI with token..."
echo "${GH_TOKEN}" | gh auth login --with-token
echo "[INFO] Authenticated gh."

# Autonomous loop stub
echo "[INFO] Running autonomous GPT agent loop..."
python3 - <<'PYTHON'
import os
# config from env
agent_name = os.getenv("AGENT_NAME")
codex_key = os.getenv("CODEX_API_KEY")
# Here you'd import your agent system modules
print(f"Agent {agent_name} running with CODEX_API_KEY={codex_key[:8]}…")
# Stub: detect GitHub event, run agent logic
# from agents.elite_team.code_ops_agent import CodeOpsAgent
# result = CodeOpsAgent(config=os.environ).run("context placeholder")
print("Autonomous loop would now process events, store memory, push to GitHub.")
PYTHON

echo "[INFO] Done."
