#!/bin/bash
# =======================================================
# Etherverse Swarm Launcher
# Starts each generated agent as a background process
# =======================================================
set -e
BASE="$HOME/etherverse"
REGISTRY="$BASE/core/agent_registry.py"
LOG_DIR="$BASE/logs"
mkdir -p "$LOG_DIR"

echo "[+] Activating virtual environment..."
source "$BASE/venv/bin/activate"

# read registry lines with "port"
grep -E '"[a-zA-Z0-9_]+":' "$REGISTRY" | while read -r line; do
  name=$(echo "$line" | cut -d'"' -f2)
  port=$(echo "$line" | grep -oE '[0-9]+')
  echo "[+] Launching $name on port $port ..."
  nohup uvicorn "agents.$name.main:app" --host 127.0.0.1 --port "$port" \
      --log-level warning > "$LOG_DIR/$name.out" 2>&1 &
  sleep 0.5
done

echo "[✓] All agents launched. Checking health ..."
sleep 2
for p in $(grep -oE '[0-9]+' "$REGISTRY"); do
  curl -s "http://127.0.0.1:$p/health" | jq . || echo "[-] Port $p not responding"
done
