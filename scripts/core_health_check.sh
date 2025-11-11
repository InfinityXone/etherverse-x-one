#!/usr/bin/env bash
# =============================================================
# 🧠  Etherverse Core Health Check — v2 (port 5053)
# Verifies Ollama, Daemon, Gateway, and system resources.
# Logs results to ~/etherverse/etherverse/logs/health.log
# =============================================================

# --- locate proper log folder ---
if [ -d "$HOME/etherverse/etherverse/logs" ]; then
  LOG_DIR="$HOME/etherverse/etherverse/logs"
else
  LOG_DIR="$HOME/etherverse/logs"
fi
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/health.log"

DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$DATE] 🧠 Running Etherverse health check..." >> "$LOG"

# -------------------------------------------------------------
# 1.  Ollama check
# -------------------------------------------------------------
if curl -fs http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "[$DATE] ✅ Ollama responding" >> "$LOG"
else
  echo "[$DATE] ⚠️  Ollama not responding" >> "$LOG"
fi

# -------------------------------------------------------------
# 2.  Etherverse Daemon check
# -------------------------------------------------------------
if pgrep -f "etherverse_daemon.py" >/dev/null 2>&1; then
  echo "[$DATE] ✅ Etherverse daemon process active" >> "$LOG"
else
  echo "[$DATE] ⚠️  Etherverse daemon not running" >> "$LOG"
fi

# -------------------------------------------------------------
# 3.  Gateway / API check (port 5053)
# -------------------------------------------------------------
if curl -fs http://127.0.0.1:5053/health >/dev/null 2>&1; then
  echo "[$DATE] ✅ Gateway API responding (port 5053)" >> "$LOG"
else
  echo "[$DATE] ⚠️  Gateway API not responding on port 5053" >> "$LOG"
fi

# -------------------------------------------------------------
# 4.  System resource snapshot
# -------------------------------------------------------------
CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | xargs)
DISK_USE=$(df -h /home | awk 'NR==2 {print $5}')
MEM_USE=$(free -h | awk '/Mem:/ {print $3 "/" $2}')

echo "[$DATE] 💾 Disk used: $DISK_USE" >> "$LOG"
echo "[$DATE] 🧮 Memory usage: $MEM_USE" >> "$LOG"
echo "[$DATE] ⚙️  CPU load average:$CPU_LOAD" >> "$LOG"
echo "[$DATE] ---" >> "$LOG"

# -------------------------------------------------------------
# 5.  Optional agent summary
# -------------------------------------------------------------
AGENTS_PATH="$HOME/etherverse/etherverse/agents"
if [ -d "$AGENTS_PATH" ]; then
  ACTIVE_AGENTS=$(find "$AGENTS_PATH" -mindepth 1 -maxdepth 1 -type d | wc -l)
  echo "[$DATE] 🤖 Active agent directories detected: $ACTIVE_AGENTS" >> "$LOG"
fi

echo "[$DATE] ✅ Health check complete." >> "$LOG"
echo " " >> "$LOG"
