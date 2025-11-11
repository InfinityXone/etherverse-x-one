#!/usr/bin/env bash
LOG="/home/etherverse/etherverse/logs/auto_heal.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$DATE] 🩺 Auto-heal cycle running..." >> "$LOG"

# --- Ollama check ---
if ! curl -fs http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "[$DATE] ⚠️  Ollama down — restarting..." >> "$LOG"
  pkill -f ollama || true
  nohup ollama serve >/dev/null 2>&1 &
fi

# --- Daemon check ---
if ! curl -fs http://127.0.0.1:5053/health >/dev/null 2>&1; then
  echo "[$DATE] ⚠️  Daemon unresponsive — restarting systemd unit..." >> "$LOG"
  sudo systemctl restart etherverse-daemon.service
else
  echo "[$DATE] ✅ Daemon healthy" >> "$LOG"
fi

echo "[$DATE] ---" >> "$LOG"
