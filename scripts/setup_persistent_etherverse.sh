#!/usr/bin/env bash
# =============================================================
# 🧠  Etherverse Persistent Infrastructure Setup — v2
# Builds full 24/7 self-healing Etherverse stack:
#  • etherverse-daemon.service (autostart/restart)
#  • etherverse-autoheal.service + timer
#  • intelligence-core-health.timer (already exists)
#  • daily backup cron
# =============================================================

set -euo pipefail

# --- ensure required directories exist ---
mkdir -p "$HOME/etherverse/scripts"
mkdir -p "$HOME/etherverse/etherverse/scripts"
mkdir -p "$HOME/etherverse/etherverse/logs"
mkdir -p "$HOME/etherverse/backups"

LOG_BASE="$HOME/etherverse/etherverse/logs"

# -------------------------------------------------------------
echo "[*] Creating systemd daemon service..."
sudo tee /etc/systemd/system/etherverse-daemon.service >/dev/null <<'EOF'
[Unit]
Description=Etherverse Daemon Service
After=network.target

[Service]
Type=simple
User=etherverse
WorkingDirectory=/home/etherverse/etherverse/agents
ExecStart=/home/etherverse/venv/bin/python3 /home/etherverse/etherverse/agents/etherverse_daemon.py
Restart=always
RestartSec=10
StartLimitIntervalSec=300
StartLimitBurst=10
StandardOutput=append:/home/etherverse/etherverse/logs/daemon.log
StandardError=append:/home/etherverse/etherverse/logs/daemon.log

[Install]
WantedBy=multi-user.target
EOF

# -------------------------------------------------------------
echo "[*] Creating auto-heal service and timer..."
sudo tee /etc/systemd/system/etherverse-autoheal.service >/dev/null <<'EOF'
[Unit]
Description=Etherverse Auto-Heal Service
After=network.target

[Service]
Type=oneshot
User=etherverse
ExecStart=/home/etherverse/scripts/auto_heal.sh
EOF

sudo tee /etc/systemd/system/etherverse-autoheal.timer >/dev/null <<'EOF'
[Unit]
Description=Run Etherverse Auto-Heal every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=etherverse-autoheal.service

[Install]
WantedBy=timers.target
EOF

# -------------------------------------------------------------
echo "[*] Creating auto-heal script..."
cat > "$HOME/etherverse/scripts/auto_heal.sh" <<'EOF'
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
EOF
chmod +x "$HOME/etherverse/scripts/auto_heal.sh"

# -------------------------------------------------------------
echo "[*] Creating daily backup script..."
cat > "$HOME/etherverse/scripts/backup_daily.sh" <<'EOF'
#!/usr/bin/env bash
# 🧠 Etherverse Daily Backup
SRC="$HOME/etherverse/etherverse"
DEST="$HOME/etherverse/backups"
DATE=$(date +%Y-%m-%d_%H-%M)
mkdir -p "$DEST"
tar -czf "$DEST/etherverse_backup_$DATE.tar.gz" "$SRC" >/dev/null 2>&1
find "$DEST" -type f -mtime +7 -delete
EOF
chmod +x "$HOME/etherverse/scripts/backup_daily.sh"

# -------------------------------------------------------------
echo "[*] Registering daily backup cron job..."
( crontab -l 2>/dev/null | grep -v 'backup_daily.sh' ; echo "0 4 * * * /home/etherverse/scripts/backup_daily.sh" ) | crontab -

# -------------------------------------------------------------
echo "[*] Reloading and enabling all services..."
sudo systemctl daemon-reload
sudo systemctl enable --now etherverse-daemon.service
sudo systemctl enable --now etherverse-autoheal.timer
sudo systemctl enable --now intelligence-core-health.timer || true

echo "[✅] Persistent Etherverse node configured and running."
echo "[→] Verify with: systemctl list-units | grep etherverse"
echo "[→] Logs: $LOG_BASE"
