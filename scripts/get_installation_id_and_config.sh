#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$HOME/etherverse-x-one/config"
mkdir -p "$CONFIG_DIR"

echo "Enter full path to your GitHub App private key (.pem):"
read -r PRIVATE_KEY_PATH
if [ ! -f "$PRIVATE_KEY_PATH" ]; then
  echo "ERROR: File not found: $PRIVATE_KEY_PATH"
  exit 1
fi

export GITHUB_APP_ID="2215740"
export GITHUB_APP_PRIVATE_KEY_PATH="$PRIVATE_KEY_PATH"

NOW=$(date +%s)
IAT=$((NOW-60))
EXP=$((NOW+600))
HEADER=$(printf '{"alg":"RS256","typ":"JWT"}' | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
PAYLOAD=$(printf '{"iat":%d,"exp":%d,"iss":"%s"}' "$IAT" "$EXP" "$GITHUB_APP_ID" | openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
HEADER_PAYLOAD="${HEADER}.${PAYLOAD}"
SIGNATURE=$(printf '%s' "${HEADER_PAYLOAD}" | openssl dgst -sha256 -sign "${PRIVATE_KEY_PATH}" | openssl base64 | tr -d '=' | tr '/+' '_-')
JWT="${HEADER_PAYLOAD}.${SIGNATURE}"

echo "[INFO] Listing installations:"
curl -s -H "Authorization: Bearer ${JWT}" -H "Accept: application/vnd.github+json" \
     "https://api.github.com/app/installations" | jq '.[] | {id,account}'

echo "Enter the Installation ID shown above:"
read -r INSTALLATION_ID

CONFIG_FILE="$CONFIG_DIR/github_app_config.sh"
cat > "$CONFIG_FILE" << EOF
export GITHUB_APP_ID="${GITHUB_APP_ID}"
export GITHUB_APP_INSTALLATION_ID="${INSTALLATION_ID}"
export GITHUB_APP_PRIVATE_KEY_PATH="${PRIVATE_KEY_PATH}"
EOF
chmod 600 "$CONFIG_FILE"
echo "Config written to $CONFIG_FILE"
read -p "Press Enter to finish…" _
