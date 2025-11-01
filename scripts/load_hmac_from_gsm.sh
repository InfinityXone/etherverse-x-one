#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT:=infinity-x-one-swarm-system}"
: "${SECRET_NAME:=hmac-secret}"
gcloud config set project "$PROJECT" >/dev/null
export HMAC_SECRET="$(gcloud secrets versions access latest --secret="$SECRET_NAME")"
echo "✅ HMAC_SECRET loaded into env (not printed)."
