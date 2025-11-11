#!/usr/bin/env bash
# =============================================================
# 🧠 Etherverse Reflection System Verifier
# Lists and opens core reflection/journey intelligence files,
# then confirms operational reflection components.
# =============================================================

set -euo pipefail

# --- Step 1: Locate main reflection documents ---
echo " "
echo "=== [1] Locating SYSTEM MODE and Quantum Intelligence Protocol ==="
find ~/etherverse -maxdepth 3 -type f \( -iname "*SYSTEM MODE*" -o -iname "*Quantum Intelligence Protocol*" \) | tee /tmp/reflection_docs.txt

# --- Step 2: Open both docs with less (read-only viewer) ---
echo " "
echo "=== [2] Opening files for verification ==="
while IFS= read -r file; do
  echo "Opening: $file"
  sleep 1
  less "$file"
done < /tmp/reflection_docs.txt

# --- Step 3: Verify that reflection/journey system components exist ---
echo " "
echo "=== [3] Checking for active reflection or journey scripts ==="
ls -lh ~/etherverse/core/daily_reflection.py 2>/dev/null || echo "daily_reflection.py not found"
ls -lh ~/etherverse/agents/*/logs/*reflect*.log 2>/dev/null || echo "reflection logs not found"
ls -lh ~/etherverse/etherverse/logs/*journey* 2>/dev/null || echo "journey logs not found"
ls -lh ~/etherverse/etherverse/logs/*wisdom* 2>/dev/null || echo "wisdom logs not found"

# --- Step 4: Confirm cron or systemd reflection triggers ---
echo " "
echo "=== [4] Listing any reflection cron jobs or timers ==="
crontab -l | grep -E "reflection|journey|wisdom" || echo "No reflection-related cron jobs found."
systemctl list-timers --all | grep -E "reflect|journey|wisdom" || echo "No reflection-related timers found."

# --- Step 5: Summary ---
echo " "
echo "[✅] Verification complete — review results above."
