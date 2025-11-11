#!/usr/bin/env bash
# ===============================================
# Etherverse Watchdog v3.1 — Self-Healing Guardian
# -----------------------------------------------
# Adds: Etherverse Daemon check + heartbeat fix
# ===============================================

LOG_DIR="/home/etherverse/etherverse/logs"
LOG_FILE="$LOG_DIR/etherverse_watchdog.log"
HEARTBEAT_LOG="$LOG_DIR/heartbeat.log"
mkdir -p "$LOG_DIR"

timestamp() { date +"%Y-%m-%d %H:%M:%S"; }

check_service() {
  local svc="$1"
  if ! systemctl is-active --quiet "$svc"; then
    echo "$(timestamp) ⚠️  $svc is down — restarting..." >> "$LOG_FILE"
    sudo systemctl restart "$svc"
    sleep 3
    if systemctl is-active --quiet "$svc"; then
      echo "$(timestamp) ✅  $svc successfully restarted" >> "$LOG_FILE"
    else
      echo "$(timestamp) ❌  $svc failed to restart" >> "$LOG_FILE"
    fi
  else
    echo "$(timestamp) ✅  $svc active" >> "$LOG_FILE"
  fi
}

check_http() {
  local name="$1"
  local url="$2"
  local svc="$3"
  local code
  code=$(curl -s --max-time 5 -o /dev/null -w "%{http_code}" "$url")
  if [[ "$code" =~ ^2[0-9][0-9]$ ]]; then
    echo "$(timestamp) 🌐  $name OK ($url)" >> "$LOG_FILE"
  else
    echo "$(timestamp) ❌  $name HTTP check failed (code $code) — restarting $svc" >> "$LOG_FILE"
    sudo systemctl restart "$svc"
  fi
}

# === Main execution ===
{
  echo "==== Watchdog run at $(timestamp) ===="

  check_service "intelligence-core.service"
  check_service "etherverse-gateway.service"
  check_service "litellm-groq.service"
  check_service "etherverse-daemon.service"  # 👈 added daemon check

  # HTTP health tests
  check_http "Etherverse Gateway" "http://127.0.0.1:8080/status" "etherverse-gateway.service"
  check_http "LiteLLM Proxy" "http://127.0.0.1:4000/v1/models" "litellm-groq.service"
  check_http "Intelligence Core" "http://127.0.0.1:5052/think" "intelligence-core.service"
  check_http "Etherverse Daemon" "http://127.0.0.1:5053/health" "etherverse-daemon.service"  # 👈 new daemon HTTP check

  # === Daily heartbeat ===
  DATE_TAG=$(date +"%Y-%m-%d")
  if ! grep -q "$DATE_TAG" "$HEARTBEAT_LOG" 2>/dev/null; then
    echo "[$(timestamp)] 💓 Watchdog active — daily heartbeat" >> "$HEARTBEAT_LOG"
  fi
  echo
} >> "$LOG_FILE" 2>&1
