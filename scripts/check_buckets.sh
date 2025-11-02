#!/usr/bin/env bash
set -euo pipefail

PROJECT="${PROJECT:-infinity-x-one-swarm-system}"
echo "[INFO] Using project: $PROJECT"
gcloud config set project "$PROJECT" >/dev/null

echo "[INFO] Listing Cloud Storage buckets in project $PROJECT"
# Use buckets list command
gcloud storage buckets list --project="$PROJECT" --format="value(name)" | \
while read BUCKET_NAME; do
  echo "• gs://$BUCKET_NAME/"
  echo "    Listing top objects (if any):"
  gcloud storage ls "gs://$BUCKET_NAME/" --project="$PROJECT" | head -n10
done

echo "[INFO] Bucket list check complete."
