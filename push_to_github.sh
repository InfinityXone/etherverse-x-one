#!/usr/bin/env bash

# Configure repository and push using a GitHub PAT.
REPO_NAME="etherverse-x-one"
REPO_OWNER="InfinityXone"
GITHUB_PAT="${GITHUB_PAT:-}"

# Prompt for the PAT if not supplied
if [[ -z "$GITHUB_PAT" ]]; then
  read -r -p "Enter your GitHub Personal Access Token (PAT): " GITHUB_PAT
fi

if [[ -z "$GITHUB_PAT" ]]; then
  echo "❌ No PAT provided. Aborting push."
  exit 1
fi

AUTH_REMOTE="https://${GITHUB_PAT}@github.com/${REPO_OWNER}/${REPO_NAME}.git"

if [[ ! -d .git ]]; then
  echo "❌ This script must be run from the root of a Git repository."
  exit 1
fi

echo "[🔗] Setting authenticated Git remote URL…"
git remote set-url origin "$AUTH_REMOTE" || {
  echo "❌ Failed to update the remote URL."
  exit 1
}

echo "[✅] Preparing to push changes…"
git add .
if ! git diff --cached --quiet; then
  COMMIT_MESSAGE="${COMMIT_MESSAGE:-"Update repository via push_to_github.sh on $(date '+%Y-%m-%d')"}"
  git commit -m "$COMMIT_MESSAGE"
else
  echo "[ℹ️] No staged changes to commit."
fi

echo "[⬆️] Pushing to the main branch…"
git push origin main || {
  echo "❌ Git push failed. Check PAT permissions or branch name."
  exit 1
}

echo "✅ Git push completed successfully."
