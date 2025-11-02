nano ~/etherverse-x-one/scripts/add_chat_ui_frontend.sh && chmod +x ~/etherverse-x-one/scripts/add_chat_ui_frontend.sh

# Paste inside:
#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$HOME/etherverse-x-one"
FRONTEND_DIR="$REPO_DIR/frontend/chat-ui"
GITHUB_USER="InfinityXone"
REPO_NAME="etherverse-x-one"

echo "🚀 Adding assistant‑ui chat frontend..."

cd "$REPO_DIR"

# 1. Clone assistant‑ui starter into frontend
rm -rf "$FRONTEND_DIR"
git clone https://github.com/assistant-ui/assistant-ui-starter.git "$FRONTEND_DIR"

# 2. Install dependencies (works if node/npm present)
cd "$FRONTEND_DIR"
npm install

# 3. Create .env.local for backend pointing
cat > .env.local <<EOF
VITE_API_URL="https://orchestrator-ru6asaa7vq-uw.a.run.app/api/chat"
EOF

# 4. Build frontend
npm run build

# 5. Stage, commit, push
cd "$REPO_DIR"
git add frontend/chat-ui
git commit -m "feat: add assistant‑ui chat frontend"
git push https://x-access-token:\$(cat /tmp/github_token)@github.com/$GITHUB_USER/$REPO_NAME.git main

echo "✅ Chat UI added and pushed. Navigate to frontend/chat-ui to run."
