#!/usr/bin/env bash
set -euo pipefail
PROJECT="${PROJECT:-infinity-x-one-swarm-system}"
REGION="${REGION:-us-east1}"
SERVICE="${SERVICE:-etherverse-orchestrator}"

gcloud config set project "$PROJECT" >/dev/null
gcloud config set run/region "$REGION" >/dev/null

# build & tag
TAG="gcr.io/$PROJECT/$SERVICE:$(date +%Y%m%d%H%M%S)"
gcloud builds submit "$HOME/etherverse-x-one" --tag "$TAG"

# deploy
gcloud run deploy "$SERVICE" \
  --image "$TAG" \
  --region "$REGION" \
  --allow-unauthenticated \
  --min-instances 0 \
  --max-instances 3 \
  --cpu 1 --memory 512Mi

URL="$(gcloud run services describe "$SERVICE" --region "$REGION" --format='value(status.url)')"
echo "Service URL: $URL"
curl -s "$URL/health" || true
