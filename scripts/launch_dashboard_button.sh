#!/bin/bash
# Etherverse Dashboard Launcher
DASH_PATH="$HOME/etherverse/analytics/dashboard.html"
if [ ! -f "$DASH_PATH" ]; then
  echo "Dashboard not found. Generating..."
  python3 ~/etherverse/core/consciousness_dashboard.py
fi
echo "[+] Opening Etherverse Consciousness Dashboard..."
/usr/bin/xdg-open "$DASH_PATH" >/dev/null 2>&1 &
