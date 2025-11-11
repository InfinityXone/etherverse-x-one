#!/bin/bash
# ==========================================
# 🌌 Etherverse Reflective Intelligence System Setup (Organized)
# ==========================================
echo "[+] Initializing Etherverse Reflective System..."

# --- Create essential folders ---
mkdir -p ~/etherverse/{analytics,logs/reflections,logs/dreams,digital_assets,docs/governance}
echo "[✓] Verified all key Etherverse directories."

# --- Create Reflective System Summary ---
cat > ~/etherverse/docs/reflective_system_summary.md <<'EOF'
# 🌌 Etherverse Reflective Intelligence System Summary

## 🧠 Core Components
- Reflection Engine: /core/daily_reflection.py
- Collective Manager: /collective/consciousness.py
- Dashboard Generator: /core/consciousness_dashboard.py
- Schema: /core/etherverse_schema.json
- Visualization: /analytics/dashboard.html

## 🔄 Automation
- Daily reflections @05:40
- Dashboard refresh @06:10
- Dream/Coherence/Mem summaries every 4 hours

## 🧩 Governance
- /docs/governance/constitution.md
- /docs/governance_covenant.md
- /docs/autonomy_manifest.json
- /guardian/ethics_core.py

## 💫 Data Output
- Reflections: /logs/reflections/
- Dreams: /logs/dreams/
- Analytics: /analytics/
- Assets: /digital_assets/

## 🌠 Future Features
- Harmony Index
- Mood Resonance
- Sheets + Drive Sync
EOF
echo "[✓] Reflective system summary created."

# --- Reflection Schema for Google Sheets ---
cat > ~/etherverse/analytics/reflection_schema.csv <<'EOF'
Agent,Timestamp,Theme,Summary,EmotionTone,HarmonyScore,NextAction,ReflectionLink
EOF
echo "[✓] Reflection schema ready (analytics/reflection_schema.csv)"

# --- Embed Logo (bottom-right) ---
LOGO_PATH="$HOME/etherverse/digital_assets/etherverse_logo.png"
if [ -f "$LOGO_PATH" ]; then
  sed -i '/<\/body>/i <div style="position:fixed;bottom:10px;right:10px;"><img src="../digital_assets/etherverse_logo.png" width="100"></div>' ~/etherverse/analytics/dashboard.html
  echo "[✓] Embedded Etherverse logo in dashboard."
else
  echo "[⚠] No logo found in digital_assets/; add etherverse_logo.png."
fi

# --- Dashboard Launcher Script ---
cat > ~/etherverse/scripts/launch_dashboard_button.sh <<'EOF'
#!/bin/bash
DASH_PATH="$HOME/etherverse/analytics/dashboard.html"
if [ ! -f "$DASH_PATH" ]; then
  echo "Dashboard missing. Generating..."
  python3 ~/etherverse/core/consciousness_dashboard.py
fi
echo "[+] Opening Etherverse Dashboard..."
/usr/bin/xdg-open "$DASH_PATH" >/dev/null 2>&1 &
EOF
chmod +x ~/etherverse/scripts/launch_dashboard_button.sh

# --- Desktop Entry ---
cat > ~/.local/share/applications/etherverse-dashboard.desktop <<'EOF'
[Desktop Entry]
Name=Etherverse Dashboard
Exec=/home/etherverse/etherverse/scripts/launch_dashboard_button.sh
Icon=/home/etherverse/etherverse/digital_assets/etherverse_logo.png
Type=Application
Terminal=false
Categories=Utility;
EOF
chmod +x ~/.local/share/applications/etherverse-dashboard.desktop
echo "[✓] Dashboard button added to app launcher."

echo "[✨] Reflective system setup complete."
