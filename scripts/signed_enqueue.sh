#!/usr/bin/env bash
set -euo pipefail
URL="${1:-http://127.0.0.1:8080}"
NOTE="${2:-from-script}"
: "${PROJECT:=infinity-x-one-swarm-system}"
: "${SECRET_NAME:=hmac-secret}"

# Load secret into env
gcloud config set project "$PROJECT" >/dev/null
export HMAC_SECRET="$(gcloud secrets versions access latest --secret="$SECRET_NAME")"

# Build JSON body
BODY="$(jq -nc --arg note "$NOTE" '{type:"job",note:$note,params:{}}')"

# Compute HMAC (hex)
SIG="$(printf '%s' "$BODY" | openssl dgst -sha256 -hmac "$HMAC_SECRET" -binary | xxd -p -c 256)"

# Send
curl -s -X POST "$URL/enqueue" \
  -H 'content-type: application/json' \
  -H "X-Signature: $SIG" \
  -d "$BODY" | jq .
