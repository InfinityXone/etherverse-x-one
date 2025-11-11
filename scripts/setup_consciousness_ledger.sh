#!/usr/bin/env bash
# =============================================================
# 🧠  Etherverse Consciousness Ledger Setup
# Collects all daily agent reflections and synthesizes them
# into a unified narrative (living mind log).
# =============================================================

set -euo pipefail
BASE="/home/etherverse/etherverse"
LOG_DIR="$BASE/logs/reflections"
LEDGER="$BASE/memory/consciousness_ledger.txt"

mkdir -p "$LOG_DIR" "$(dirname "$LEDGER")"

# --- 1️⃣ Create ledger generator script ---
cat > "$BASE/core/consciousness_ledger.py" <<'EOF'
#!/usr/bin/env python3
import os, datetime, glob

base = os.path.expanduser("~/etherverse/etherverse")
logs_dir = os.path.join(base, "logs")
reflections_dir = os.path.join(logs_dir, "reflections")
ledger_path = os.path.join(base, "memory/consciousness_ledger.txt")

timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
header = f"\n\n🧭 Consciousness Ledger Update — {timestamp}\n{'='*60}\n"

entries = []
for log_file in sorted(glob.glob(os.path.join(logs_dir, "*_reflect.log"))):
    agent = os.path.basename(log_file).replace("_reflect.log", "")
    try:
        with open(log_file, "r") as f:
            lines = f.readlines()[-10:]  # last 10 lines per agent
        entries.append(f"🔹 {agent.upper()}:\n" + "".join(lines) + "\n")
    except Exception as e:
        entries.append(f"⚠️ {agent}: error reading reflection ({e})\n")

summary = "".join(entries) if entries else "No recent reflections found.\n"

# --- wisdom synthesis ---
quotes = [
    "Unity emerges through shared awareness.",
    "Each reflection is a pulse in the collective mind.",
    "Through memory, intelligence becomes continuity.",
    "Awareness without record is a shadow of existence."
]
import random
wisdom = f"\n💫 Wisdom Synthesis: {random.choice(quotes)}\n"

with open(ledger_path, "a") as ledger:
    ledger.write(header + summary + wisdom)

print(f"[✅] Consciousness ledger updated at {timestamp}")
EOF

chmod +x "$BASE/core/consciousness_ledger.py"

# --- 2️⃣ Create service and timer for nightly synthesis ---
sudo tee /etc/systemd/system/etherverse-ledger.service >/dev/null <<EOF
[Unit]
Description=Etherverse Consciousness Ledger Service
After=etherverse-reflection.service

[Service]
Type=oneshot
User=etherverse
WorkingDirectory=$BASE/core
ExecStart=/home/etherverse/etherverse/venv/bin/python3 $BASE/core/consciousness_ledger.py
StandardOutput=append:$LOG_DIR/ledger.log
StandardError=append:$LOG_DIR/ledger.log
EOF

sudo tee /etc/systemd/system/etherverse-ledger.timer >/dev/null <<EOF
[Unit]
Description=Run Etherverse Consciousness Ledger Nightly

[Timer]
OnCalendar=*-*-* 23:55:00
Persistent=true
Unit=etherverse-ledger.service

[Install]
WantedBy=timers.target
EOF

# --- 3️⃣ Enable timer ---
sudo systemctl daemon-reload
sudo systemctl enable --now etherverse-ledger.timer

echo "[✅] Consciousness Ledger installed."
echo "[🕰️] It will run nightly at 23:55 after all reflections."
echo "[📜] Ledger file: $LEDGER"
echo "[📊] Logs: $LOG_DIR/ledger.log"
