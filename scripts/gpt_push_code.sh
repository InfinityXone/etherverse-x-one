#!/bin/bash

set -e

REPO_NAME="etherverse-x-one"
GIT_EMAIL="gpt@etherverse.ai"
GIT_USER="Infinity Agent"
GITHUB_USER="InfinityXone"
GITHUB_TOKEN="$(cat /tmp/github_token)"

echo "🔧 Configuring Git identity..."
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_USER"

echo "📦 Cloning repo..."
rm -rf /tmp/$REPO_NAME
git clone https://x-access-token:$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git /tmp/$REPO_NAME

cd /tmp/$REPO_NAME

echo "📄 Writing test agent..."
mkdir -p agents
echo "# 🤖 Auto-generated Alpha agent" > agents/alpha.py

git add agents/alpha.py
git commit -m "🤖 Add Alpha agent template"

echo "🚀 Pushing to main..."
git push https://x-access-token:$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO_NAME.git HEAD:main
