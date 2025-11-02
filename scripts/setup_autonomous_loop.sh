#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$HOME/etherverse-x-one/scripts/github_app_autonomous_loop.sh"

mkdir -p "$(dirname "$SCRIPT_PATH")"

cat > "$SCRIPT_PATH" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail

# Config constants
export AGENT_NAME="Infinity Agent"
export CODEX_API_KEY="098dad28f0cca0b17842e37f33d081422d1dbe11dbcbefd9e3c86068500754bb"
export AGENT_ROLE="Infinity Agent"
export P_WHITELIST="127.0.0.1,192.168.0.0/24"
export IPC_SOCKET_PATH="/tmp/agent_one.sock"

# GitHub App credentials — fill these in:
export GITHUB_APP_ID="2215740"
export GITHUB_APP_INSTALLATION_ID="<YOUR_INSTALLATION_ID>"
export GITHUB_APP_PRIVATE_KEY_PATH="/path/to/your/github-app-private-key.pem"

echo "[INFO] Generating JWT for GitHub App..."
NOW=$(date +%s)
IAT=$((NOW-60))
EXP=$((NOW+600))
HEADER=$(printf '{"alg":"RS256","typ":"JWT"}' | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
PAYLOAD=$(printf '{"iat":%d,"exp":%d,"iss":"%s"}' "$IAT" "$EXP" "$GITHUB_APP_ID" | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
HEADER_PAYLOAD="${HEADER}.${PAYLOAD}"
SIGNATURE=$(printf '%s' "${HEADER_PAYLOAD}" | openssl dgst -sha256 -sign "${GITHUB_APP_PRIVATE_KEY_PATH}" | openssl base64 | tr -d '=' | tr '/+' '_-')
JWT="${HEADER_PAYLOAD}.${SIGNATURE}"

echo "[INFO] Requesting installation access token..."
TOKEN=$(curl -s -X POST \
  -H "Authorization: Bearer ${JWT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/app/installations/${GITHUB_APP_INSTALLATION_ID}/access_tokens" \
  | jq -r .token)

export GH_TOKEN="${TOKEN}"
echo "[INFO] GH installation access token stored in GH_TOKEN."

echo "[INFO] Logging into GitHub CLI..."
echo "${GH_TOKEN}" | gh auth login --with-token
echo "[INFO] GitHub CLI logged in."

echo "[INFO] Launching autonomous agent stub..."
python3 - <<'PYTHON'
import os
agent_name = os.getenv("AGENT_NAME")
codex_key = os.getenv("CODEX_API_KEY")
print(f"Agent {agent_name} starting with CODEX API key prefix: {codex_key[:8]}…")
# TODO: invoke your agent logic here
# from agents.elite_team.code_ops_agent import CodeOpsAgent
# result = CodeOpsAgent(config=os.environ).run("context placeholder")
print("Stub complete.")
PYTHON

echo "[INFO] Script end — review logs above."
BASH

chmod +x "$SCRIPT_PATH"

echo "Script created at: $SCRIPT_PATH"
echo "Opening editor so you can adjust installation ID & key path."
nano "$SCRIPT_PATH"

echo "When you are done editing, you can launch the script via:"
echo "  $SCRIPT_PATH"
