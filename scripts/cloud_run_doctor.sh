#!/usr/bin/env bash
set -euo pipefail

PROJECT="${PROJECT:-infinity-x-one-swarm-system}"
REGION="${REGION:-us-east1}"
API_SERVICE="${API_SERVICE:-etherverse-api}"
WORKER_SERVICE="${WORKER_SERVICE:-etherverse-orchestrator}"
IMAGE_REPO="${IMAGE_REPO:-us-east1-docker.pkg.dev/$PROJECT/$REGION-docker}"
IMAGE_TAG="${IMAGE_TAG:-$(date +%Y%m%d-%H%M%S)}"
API_IMAGE="$IMAGE_REPO/$API_SERVICE:$IMAGE_TAG"
WORKER_IMAGE="$IMAGE_REPO/$WORKER_SERVICE:$IMAGE_TAG"

echo "[INFO] Setting gcloud project to '$PROJECT'"
gcloud config set project "$PROJECT" >/dev/null
gcloud config set run/region "$REGION" >/dev/null

if [ ! -f requirements.txt ]; then
  echo "[ERROR] requirements.txt not found"; exit 1
fi
echo "[INFO] requirements.txt found"

echo "[INFO] Building API image: $API_IMAGE"
gcloud builds submit . --tag "$API_IMAGE" --timeout=30m

echo "[INFO] Deploying API service '$API_SERVICE'"
gcloud run deploy "$API_SERVICE" --image "$API_IMAGE" --region "$REGION" --allow-unauthenticated --quiet
API_URL=$(gcloud run services describe "$API_SERVICE" --region "$REGION" --format='value(status.url)')
echo "[INFO] API URL: $API_URL"

echo "[INFO] Checking /health endpoint"
curl -fsS "$API_URL/health" >/dev/null && echo "[INFO] /health OK" || { echo "[ERROR] /health failed"; exit 1; }

echo "[INFO] Testing signed enqueue endpoint"
BODY='{"type":"job","note":"doctor-check","params":{}}'
HMAC_SECRET=$(gcloud secrets versions access latest --secret='hmac-secret')
SIG=$(printf '%s' "$BODY" | openssl dgst -sha256 -hmac "$HMAC_SECRET" -binary | xxd -p -c 256)
RESPONSE=$(curl -sS -X POST "$API_URL/enqueue" -H "content-type: application/json" -H "X-Signature:$SIG" -d "$BODY")
echo "[INFO] Enqueue response: $RESPONSE"

echo "[INFO] Doctor check complete."
