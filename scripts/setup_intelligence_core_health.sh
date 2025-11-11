#!/usr/bin/env bash
# =============================================================
# 🧠 Etherverse Intelligence Core Health Setup
# Creates systemd service + timer for periodic health checks.
# =============================================================

set -euo pipefail

# === 1. Configuration ===
SERVICE_NAME="intelligence-core-health"
INTERVAL="${1:-10min}"  # use custom interval like "5min" or "1h" as arg
CHECK_SCRIPT="$HOME/etherverse/scripts/core_health_check.sh"
LOG_DIR="$HOME/etherverse/logs"
LOG_FILE="$LOG_DIR/health.log"

echo "[*] Setting up $SERVICE_NAME to run every $INTERVAL..."

mkdir -p "$LOG_DIR" "$HOME/etherverse/scripts"

# === 2. Write the core health-check script ===
cat > "$CHECK_SCRIPT" <<'EOF'
#!/usr/bin/env bash
LOG="$HOME/etherverse/logs/health.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$DATE] 🧠 Running Etherverse core health check..." >> "$LOG"

# --- Ollama check ---
if curl -fs http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "[$DATE] ✅ Ollama responding" >> "$LOG"
else
  echo "[$DATE] ⚠️  Ollama not responding" >> "$LOG"
fi

# --- Gateway or Daemon check ---
if pgrep -f "etherverse_daemon.py" >/dev/null 2>&1; then
  echo "[$DATE] ✅ Etherverse daemon active" >> "$LOG"
else
  echo "[$DATE] ⚠️  Etherverse daemon not running" >> "$LOG"
fi

# --- Disk usage snapshot ---
df -h /home | awk 'NR==2 {print "[$DATE] 💾 Disk used: " $5}' >> "$LOG"

echo "[$DATE] ---" >> "$LOG"
EOF

chmod +x "$CHECK_SCRIPT"

# === 3. Create systemd service ===
sudo bash -c "cat > /etc/systemd/system/${SERVICE_NAME}.service" <<EOF
[Unit]
Description=Check Etherverse Intelligence Core health

[Service]
Type=oneshot
ExecStart=$CHECK_SCRIPT
EOF

# === 4. Create systemd timer ===
sudo bash -c "cat > /etc/systemd/system/${SERVICE_NAME}.timer" <<EOF
[Unit]
Description=Run Etherverse Intelligence Core health check every $INTERVAL

[Timer]
OnBootSec=2min
OnUnitActiveSec=$INTERVAL
Unit=${SERVICE_NAME}.service
Persistent=true

[Install]
WantedBy=timers.target
EOF

# === 5. Enable and start ===
sudo systemctl daemon-reload
sudo systemctl enable --now ${SERVICE_NAME}.timer

echo "[✓] $SERVICE_NAME.timer enabled."
systemctl list-timers --all | grep ${SERVICE_NAME}
echo "[✅] Logs will appear in: $LOG_FILE"
