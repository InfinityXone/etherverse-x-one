#!/bin/bash
# ======================================================
# 🌌 Etherverse Total Initialization Script
# Builds agentic folder structure, installs core logic,
# sets crons, dashboards, and mind-state cycles.
# ======================================================

echo "[*] Initializing Etherverse Quantum-AI system..."

mkdir -p ~/etherverse/{core,agents,docs,logs,memory,analytics,dashboard,scripts}

# === Core Folders Verification ===
echo "===== 🧠 Etherverse Quantum System Verification ====="
for d in core agents scripts docs memory analytics logs; do
  DIR="$HOME/etherverse/$d"
  if [ -d "$DIR" ]; then
    echo "[✓] $DIR exists."
  else
    echo "[✗] $DIR missing — creating..."
    mkdir -p "$DIR"
  fi
done

# === Project Structure Index ===
cat > ~/etherverse/scripts/list_project_structure.sh <<'EOF'
#!/bin/bash
cd ~/etherverse || exit
echo "===== 🧠 Etherverse Project Structure ====="
find . -type d \( -name "venv" -o -name "__pycache__" -o -name ".git" \) -prune -false -o \
    -type f -print | grep -Ev "(__pycache__|\.pyc|\.log|\.tmp|\.swp)" | sort
echo "=========================================="
EOF

chmod +x ~/etherverse/scripts/list_project_structure.sh
bash ~/etherverse/scripts/list_project_structure.sh > ~/etherverse/docs/project_structure.txt

# === Launch Dashboard Button Script ===
cat > ~/etherverse/scripts/launch_dashboard_button.sh <<'EOF'
#!/bin/bash
# Etherverse Dashboard Launcher
DASH_PATH="$HOME/etherverse/analytics/dashboard.html"
if [ ! -f "$DASH_PATH" ]; then
  echo "Dashboard not found. Generating..."
  python3 ~/etherverse/core/consciousness_dashboard.py
fi
echo "[+] Opening Etherverse Consciousness Dashboard..."
/usr/bin/xdg-open "$DASH_PATH" >/dev/null 2>&1 &
EOF

chmod +x ~/etherverse/scripts/launch_dashboard_button.sh

# === Desktop Shortcut ===
cat > ~/.local/share/applications/etherverse-dashboard.desktop <<'EOF'
[Desktop Entry]
Name=Etherverse Dashboard
Exec=/home/etherverse/etherverse/scripts/launch_dashboard_button.sh
Icon=utilities-terminal
Type=Application
Terminal=false
Categories=Utility;
EOF

chmod +x ~/.local/share/applications/etherverse-dashboard.desktop

# === Run Structure Verifier Script ===
cat > ~/etherverse/scripts/verify_quantum_system.sh <<'EOF'
#!/bin/bash
echo "===== 🧠 Etherverse Quantum System Verification ====="
for d in core agents scripts docs memory analytics logs; do
  DIR="$HOME/etherverse/$d"
  if [ -d "$DIR" ]; then
    echo "[✓] $HOME/etherverse/$d exists."
  else
    echo "[✗] $HOME/etherverse/$d missing."
  fi
done
EOF

chmod +x ~/etherverse/scripts/verify_quantum_system.sh
~/etherverse/scripts/verify_quantum_system.sh

# === Install Quantum Intelligence Cycle CRON ===
(crontab -l 2>/dev/null; echo "40 6 * * * ~/etherverse/scripts/quantum_intelligence_cycle.sh") | crontab -

# === Reflective Agent Crons ===
for a in aria codeops coder codex corelight devops echo eden finops finsynapse gateway guardian helix insight market orchestrator pickybot planner promptwriter quantum scheduler strategy telemetry traffic vision wallet_ops; do
  (crontab -l 2>/dev/null; echo "40 5 * * * AGENT=$a python3 ~/etherverse/core/daily_reflection.py >> ~/etherverse/logs/${a}_reflect.log 2>&1") | crontab -
done

# === Idle Dream Cron ===
(crontab -l 2>/dev/null; echo "0 */4 * * * ~/etherverse/scripts/idle_dream_state.py") | crontab -

# === Dream Visualizer + Memory Summarizer ===
(crontab -l 2>/dev/null; echo "15 7 * * * ~/etherverse/scripts/dream_visualizer.py") | crontab -
(crontab -l 2>/dev/null; echo "55 7 * * * ~/etherverse/scripts/memory_summarizer.py") | crontab -

echo "[✓] Total Init Complete — Etherverse structure and cycles are active."
