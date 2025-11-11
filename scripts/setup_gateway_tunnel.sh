#!/usr/bin/env bash
set -euo pipefail
# Etherverse Stage: Gateway + Tunnel + Persistent Agents + Self-Heal + Smoke Test
# Place this file in ~/etherverse/scripts/setup_gateway_tunnel.sh, chmod +x and run.
# Optional: export REMOTE_SSH_HOST, REMOTE_SSH_PORT, REMOTE_SSH_USER, REMOTE_SSH_REMOTE_PORT, REMOTE_SSH_KEY before running

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BASE="$HOME/etherverse"
SCRIPTS="$BASE/scripts"
LOGS="$BASE/logs"
WG_DIR="$BASE/wireguard"
REPORT="$BASE/setup_report_$TIMESTAMP.txt"
GATEWAY_PORT=8080
WG_PORT=51820
AUTOSSH_SERVICE_NAME="autossh-etherverse.service"

mkdir -p "$SCRIPTS" "$LOGS" "$WG_DIR" "$BASE/agents"

echo "[*] Starting Etherverse Gateway+Tunnel setup at $(date)" | tee "$REPORT"

# --- apt prep & installs ---
echo "[*] Updating apt and installing packages..." | tee -a "$REPORT"
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  python3-venv python3-pip python3-openssl curl gnupg2 \
  wireguard iproute2 ufw fail2ban autossh git jq

# docker is optional but useful; skip install if already present
if ! command -v docker >/dev/null 2>&1; then
  echo "[*] Docker not found — attempting apt install docker.io" | tee -a "$REPORT"
  sudo apt-get install -y docker.io
  sudo systemctl enable --now docker || true
fi

# --- create Python venv + gateway app ---
echo "[*] Creating Python venv and gateway app..." | tee -a "$REPORT"
python3 -m venv "$BASE/venv"
source "$BASE/venv/bin/activate"
pip install --upgrade pip >/dev/null
pip install fastapi uvicorn pydantic starlette >/dev/null

# gateway app (FastAPI)
cat > "$BASE/gateway.py" <<'PY'
from fastapi import FastAPI, Request
import uvicorn, json, os, subprocess, datetime

app = FastAPI(title="Etherverse Gateway")

@app.get("/health")
async def health():
    return {"status":"alive", "time": str(datetime.datetime.utcnow())}

@app.post("/task")
async def task(req: Request):
    payload = await req.json()
    # This is a light placeholder. Agents should implement business logic.
    # Log the received payload and return an ack.
    with open(os.path.expanduser("~/etherverse/logs/gateway_tasks.log"), "a") as f:
        f.write(f"{datetime.datetime.utcnow().isoformat()} | {json.dumps(payload)}\n")
    return {"ok": True, "received": payload}

if __name__ == "__main__":
    uvicorn.run("gateway:app", host="0.0.0.0", port=int(os.getenv("GATEWAY_PORT", "8080")))
PY

# convenience start script
cat > "$SCRIPTS/start_gateway.sh" <<'BASH'
#!/usr/bin/env bash
source ~/etherverse/venv/bin/activate
export GATEWAY_PORT=8080
nohup python3 ~/etherverse/gateway.py > ~/etherverse/logs/gateway.stdout 2>&1 &
echo "[+] Gateway started"
BASH
chmod +x "$SCRIPTS/start_gateway.sh"
bash "$SCRIPTS/start_gateway.sh"

# systemd unit for gateway
sudo tee /etc/systemd/system/etherverse-gateway.service >/dev/null <<'UNIT'
[Unit]
Description=Etherverse Gateway (FastAPI)
After=network.target

[Service]
User=$USER
WorkingDirectory=$BASE
ExecStart=$BASE/venv/bin/python3 $BASE/gateway.py
Restart=always
RestartSec=3
Environment=GATEWAY_PORT=$GATEWAY_PORT

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now etherverse-gateway.service

# --- seed agents (stubs) ---
for agent in architect builder guardian; do
  cat > "$BASE/agents/$agent.py" <<PY
#!/usr/bin/env python3
import time, json, os, requests
LOG="$BASE/logs/${agent}.log"
def log(msg):
    with open(LOG, "a") as f:
        f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} | {msg}\\n")
log("Starting $agent")
# simple loop: ping gateway health and write heartbeat
while True:
    try:
        r = requests.get("http://127.0.0.1:$GATEWAY_PORT/health", timeout=5)
        log(f"health:{r.json()}")
    except Exception as e:
        log(f"err:{e}")
    time.sleep(10)
PY
  chmod +x "$BASE/agents/$agent.py"
  sudo tee /etc/systemd/system/etherverse-$agent.service >/dev/null <<UNIT
[Unit]
Description=Etherverse Agent - $agent
After=network.target

[Service]
User=$USER
WorkingDirectory=$BASE
ExecStart=$BASE/venv/bin/python3 $BASE/agents/$agent.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT
  sudo systemctl enable --now "etherverse-$agent.service"
done

# --- firewall & fail2ban ---
echo "[*] Configuring UFW firewall and fail2ban..." | tee -a "$REPORT"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw allow $GATEWAY_PORT/tcp
sudo ufw allow $WG_PORT/udp
sudo ufw --force enable
sudo systemctl enable --now fail2ban

# --- WireGuard key generation + config ---
echo "[*] Generating WireGuard keys and config..." | tee -a "$REPORT"
WG_PRIV="$WG_DIR/wg_private.key"
WG_PUB="$WG_DIR/wg_public.key"
WG_CONF="/etc/wireguard/wg0.conf"
if [ ! -f "$WG_PRIV" ]; then
  umask 077
  wg genkey | tee "$WG_PRIV" | wg pubkey > "$WG_PUB"
fi
WG_PRIV_KEY="$(cat $WG_PRIV)"
WG_PUB_KEY="$(cat $WG_PUB)"
INTERNAL_IP="10.99.99.1/24"

sudo tee "$WG_CONF" >/dev/null <<WGCONF
[Interface]
Address = $INTERNAL_IP
SaveConfig = true
ListenPort = $WG_PORT
PrivateKey = $WG_PRIV_KEY

# Client peers should be added below (manual or via automation)
WGCONF

sudo chmod 600 "$WG_CONF"
sudo systemctl enable --now wg-quick@wg0 || true
sleep 2

# create a sample peer block for remote copy
PEER_PRIV="$WG_DIR/peer_private.key"
PEER_PUB="$WG_DIR/peer_public.key"
if [ ! -f "$PEER_PRIV" ]; then
  wg genkey | tee "$PEER_PRIV" | wg pubkey > "$PEER_PUB"
fi
PEER_PRIV_KEY="$(cat $PEER_PRIV)"
PEER_PUB_KEY="$(cat $PEER_PUB)"
cat > "$WG_DIR/peer_peer.conf" <<PEER
[Interface]
PrivateKey = $PEER_PRIV_KEY
Address = 10.99.99.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = $WG_PUB_KEY
Endpoint = YOUR_SEED_IP_OR_DDNS_HERE:${WG_PORT}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
PEER

echo "[*] WireGuard peer config saved to $WG_DIR/peer_peer.conf" | tee -a "$REPORT"

# --- optional: autossh reverse tunnel if REMOTE_SSH_* vars are present ---
if [[ -n "${REMOTE_SSH_HOST:-}" ]] && [[ -n "${REMOTE_SSH_USER:-}" ]] && [[ -n "${REMOTE_SSH_REMOTE_PORT:-}" ]]; then
  echo "[*] Configuring autossh reverse tunnel to $REMOTE_SSH_HOST (remote port $REMOTE_SSH_REMOTE_PORT)..." | tee -a "$REPORT"
  AUTOSSH_PORT="${REMOTE_SSH_REMOTE_PORT}"
  AUTOSSH_KEY="${REMOTE_SSH_KEY:-$HOME/.ssh/id_rsa}"
  AUTOSSH_HOST="${REMOTE_SSH_HOST}"
  AUTOSSH_USER="${REMOTE_SSH_USER}"
  AUTOSSH_REMOTE_PORT="${REMOTE_SSH_REMOTE_PORT}"
  # systemd unit
  sudo tee /etc/systemd/system/$AUTOSSH_SERVICE_NAME >/dev/null <<AUTOSSHUNIT
[Unit]
Description=autossh reverse tunnel for Etherverse
After=network.target

[Service]
User=$USER
Environment="AUTOSSH_GATETIME=0"
ExecStart=/usr/bin/autossh -M 0 -N -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -R ${AUTOSSH_REMOTE_PORT}:localhost:${GATEWAY_PORT} -i ${AUTOSSH_KEY} ${AUTOSSH_USER}@${AUTOSSH_HOST}
Restart=always
RestartSec=8

[Install]
WantedBy=multi-user.target
AUTOSSHUNIT
  sudo systemctl daemon-reload
  sudo systemctl enable --now "$AUTOSSH_SERVICE_NAME"
else
  echo "[*] REMOTE_SSH_* not provided — skipping autossh setup. Provide REMOTE_SSH_HOST/REMOTE_SSH_USER/REMOTE_SSH_REMOTE_PORT env vars to enable." | tee -a "$REPORT"
fi

# --- tuner / watchdog (self healing) ---
cat > "$SCRIPTS/etherverse_tuner.sh" <<'TUNER'
#!/usr/bin/env bash
# Simple tuner: checks gateway and agents; restarts service if needed.
while true; do
  TS=$(date +%s)
  OUT="$HOME/etherverse/logs/tuner_$(date +%Y%m%d).log"
  echo "$TS :: tuner check" >> "$OUT"
  # gateway health
  if ! curl -sS http://127.0.0.1:8080/health >/dev/null 2>&1; then
    echo "$TS :: gateway unhealthy - restarting" >> "$OUT"
    systemctl restart etherverse-gateway.service
    sleep 3
  fi
  # agents
  for svc in etherverse-architect.service etherverse-builder.service etherverse-guardian.service; do
    if ! systemctl is-active --quiet "$svc"; then
      echo "$TS :: $svc inactive - restarting" >> "$OUT"
      systemctl restart "$svc"
    fi
  done
  # autossh health (if present)
  if systemctl list-units --type=service | grep -q autossh-etherverse; then
    if ! systemctl is-active --quiet autossh-etherverse.service; then
      echo "$TS :: autossh inactive - restarting" >> "$OUT"
      systemctl restart autossh-etherverse.service
    fi
  fi
  # free memory check and prune docker if memory low
  FREE=$(free -m | awk '/^Mem:/{print $7}')
  if [ "$FREE" -lt 200 ]; then
    echo "$TS :: low mem($FREE MB) - clearing docker system and caches" >> "$OUT"
    docker system prune -af || true
    sync; echo 3 > /proc/sys/vm/drop_caches || true
  fi
  sleep 20
done
TUNER
chmod +x "$SCRIPTS/etherverse_tuner.sh"
sudo tee /etc/systemd/system/etherverse-tuner.service >/dev/null <<TUNERUNIT
[Unit]
Description=Etherverse Tuner (Self-Heal Watchdog)
After=network.target

[Service]
User=$USER
WorkingDirectory=$BASE
ExecStart=$SCRIPTS/etherverse_tuner.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
TUNERUNIT
sudo systemctl daemon-reload
sudo systemctl enable --now etherverse-tuner.service

# --- final smoke tests ---
echo "[*] Running smoke tests..." | tee -a "$REPORT"
sleep 3
echo "==== ETHERVERSE SETUP REPORT ($TIMESTAMP) ====" >> "$REPORT"
echo "Gateway (systemd):" >> "$REPORT"
systemctl status etherverse-gateway.service --no-pager >> "$REPORT" 2>&1 || true
echo "" >> "$REPORT"
for svc in etherverse-architect.service etherverse-builder.service etherverse-guardian.service etherverse-tuner.service; do
  echo "Service: $svc" >> "$REPORT"
  systemctl is-active --quiet "$svc" && echo "ACTIVE" >> "$REPORT" || echo "INACTIVE" >> "$REPORT"
  systemctl status "$svc" --no-pager >> "$REPORT" 2>&1 || true
  echo "" >> "$REPORT"
done

# test gateway endpoint
if curl -sS "http://127.0.0.1:$GATEWAY_PORT/health" >/dev/null 2>&1; then
  echo "Gateway health: OK" | tee -a "$REPORT"
else
  echo "Gateway health: FAIL" | tee -a "$REPORT"
fi

# wireguard status
if command -v wg >/dev/null 2>&1; then
  echo "WireGuard status:" >> "$REPORT"
  wg show >> "$REPORT" 2>&1 || true
fi

# autossh status
if systemctl list-units --type=service | grep -q "$AUTOSSH_SERVICE_NAME"; then
  echo "autossh service status:" >> "$REPORT"
  systemctl status "$AUTOSSH_SERVICE_NAME" --no-pager >> "$REPORT" 2>&1 || true
else
  echo "autossh: not configured" >> "$REPORT"
fi

# firewall
echo "UFW status:" >> "$REPORT"
sudo ufw status verbose >> "$REPORT" 2>&1 || true

# final notes + wireguard peer sample
echo "" >> "$REPORT"
echo "WireGuard peer config for remote device (copy to remote machine and adjust Endpoint):" >> "$REPORT"
echo "------" >> "$REPORT"
cat "$WG_DIR/peer_peer.conf" >> "$REPORT"
echo "------" >> "$REPORT"

echo "Report saved to $REPORT"
echo "[*] Setup complete. Review $REPORT for details and next steps." | tee -a "$REPORT"

# print short console summary
echo "==== SUMMARY ===="
echo "Gateway: http://127.0.0.1:$GATEWAY_PORT  (systemd: etherverse-gateway.service)"
echo "Agents: etherverse-architect/builder/guardian (systemd services)"
if systemctl is-active --quiet "$AUTOSSH_SERVICE_NAME"; then
  echo "Reverse tunnel: enabled via autossh (service: $AUTOSSH_SERVICE_NAME)"
else
  echo "Reverse tunnel: NOT enabled. To enable, export REMOTE_SSH_HOST/REMOTE_SSH_USER/REMOTE_SSH_REMOTE_PORT and re-run this script."
fi
echo "WireGuard peer config: $WG_DIR/peer_peer.conf"
echo "Full report: $REPORT"
