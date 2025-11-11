#!/bin/bash
echo "[+] Injecting mind-state awareness into all agent files..."

AGENT_DIR=~/etherverse/agents
COHERENCE_PATH="$HOME/etherverse/docs/coherence_summary.md"

for f in "$AGENT_DIR"/*.py; do
  [ -f "$f" ] || continue
  if ! grep -q "COHERENCE_PATH" "$f"; then
    cat >> "$f" <<'EOF'

# --- Etherverse Shared Mind-State Awareness ---
import os
COHERENCE_PATH = os.path.expanduser("~/etherverse/docs/coherence_summary.md")
if os.path.exists(COHERENCE_PATH):
    with open(COHERENCE_PATH, "r", encoding="utf-8") as _mind:
        recent_state = _mind.read()
        print(f"[+] {os.path.basename(__file__)} loaded Etherverse mind-state snapshot.")
else:
    print("[!] No coherence_summary.md found — running in local-memory mode.")
# ------------------------------------------------
EOF
    echo "[✓] Injected into $(basename "$f")"
  else
    echo "[=] $(basename "$f") already contains awareness code."
  fi
done
