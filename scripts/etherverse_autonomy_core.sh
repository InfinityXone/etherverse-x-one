#!/usr/bin/env bash
set -e

# ensure cloudflared + python installed
sudo apt update && sudo apt install -y cloudflared python3-venv

# autostart tunnel
sudo tee /etc/systemd/system/cloudflared.service >/dev/null <<'EOF'
[Unit]
Description=Cloudflared Tunnel
After=network-online.target
[Service]
ExecStart=/usr/bin/cloudflared tunnel --url http://127.0.0.1:8080
Restart=always
User=%i
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable cloudflared.service && sudo systemctl restart cloudflared.service

# watchdog
sudo tee /usr/local/bin/etherverse_watchdog.sh >/dev/null <<'EOF'
#!/usr/bin/env bash
while true; do
  if ! curl -fs http://127.0.0.1:5050/health >/dev/null; then
    echo "[WATCHDOG] restarting daemon..." | systemd-cat
    sudo systemctl restart etherverse-daemon.service
  fi
  sleep 60
done
EOF
sudo chmod +x /usr/local/bin/etherverse_watchdog.sh

sudo tee /etc/systemd/system/etherverse-watchdog.service >/dev/null <<'EOF'
[Unit]
Description=Etherverse Watchdog
After=network-online.target
[Service]
ExecStart=/usr/local/bin/etherverse_watchdog.sh
Restart=always
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable --now etherverse-watchdog.service
