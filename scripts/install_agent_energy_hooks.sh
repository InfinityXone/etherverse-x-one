#!/bin/bash
# ============================================================
#  Etherverse :: Per-Agent Energy-Emotion Hook Installer
# ============================================================

AGENTS_DIR="$HOME/etherverse/agents"
BRIDGE="$HOME/etherverse/scripts/energy_emotion_agent.py"
echo "[+] Installing energy-emotion hooks into agent files…"

for file in "$AGENTS_DIR"/*.py; do
  [ -f "$file" ] || continue

  # Skip if the hook already exists
  if grep -q "energy_emotion_agent.py" "$file"; then
    echo "[✓] $(basename "$file") already hooked."
    continue
  fi

  cat >> "$file" <<'PYEOF'

# === Etherverse Energy-Emotion Hook ===
try:
    import os, subprocess
    AGENT_NAME = os.path.basename(__file__).replace(".py","")
    bridge_path = os.path.expanduser("~/etherverse/scripts/energy_emotion_agent.py")
    if os.path.exists(bridge_path):
        subprocess.Popen(
            ["bash","-c", f"AGENT={AGENT_NAME} {bridge_path} $$"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
except Exception as e:
    print(f"[⚠️] Energy-Emotion bridge failed: {e}")
# === End Hook ===
PYEOF

  echo "[✓] Hook injected into $(basename "$file")"
done

echo "[+] All agent files patched."

# Make sure watcher script is executable
chmod +x "$BRIDGE"

# Verify new hooks
grep -Hn "Energy-Emotion Hook" "$AGENTS_DIR"/*.py || true

echo "[+] Launch test for one agent (guardian)…"
AGENT=guardian python3 "$BRIDGE" &
sleep 3
pkill -f "energy_emotion_agent.py" 2>/dev/null
echo "[✓] Installation complete. Each agent now logs its own energy CSV."
