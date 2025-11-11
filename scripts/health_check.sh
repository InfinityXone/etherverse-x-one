#!/bin/bash
# Etherverse Intelligence Core health monitor
LOGFILE="/home/etherverse/etherverse/logs/intelligence_core_health.log"
SERVICE="intelligence-core.service"
URL="http://127.0.0.1:5052/think"
FAILCOUNT_FILE="/tmp/intelligence_core_failcount"

# Create log dir if needed
mkdir -p "$(dirname "$LOGFILE")"

# Perform a quick test
response=$(curl -s -m 5 -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d '{"prompt":"health check","role":"watchdog"}' | grep -o "Reflective")

if [[ "$response" == "Reflective" ]]; then
  echo "$(date '+%F %T') ✅ Core responding." >> "$LOGFILE"
  echo 0 > "$FAILCOUNT_FILE"
else
  echo "$(date '+%F %T') ⚠️ Core unresponsive." >> "$LOGFILE"
  failcount=$(cat "$FAILCOUNT_FILE" 2>/dev/null || echo 0)
  failcount=$((failcount+1))
  echo "$failcount" > "$FAILCOUNT_FILE"

  if (( failcount >= 3 )); then
    echo "$(date '+%F %T') 🔁 Restarting $SERVICE after 3 failures." >> "$LOGFILE"
    sudo systemctl restart "$SERVICE"
    echo 0 > "$FAILCOUNT_FILE"
  fi
fi
