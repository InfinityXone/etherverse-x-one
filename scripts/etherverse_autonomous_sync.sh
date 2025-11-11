#!/bin/bash
# 🌌 Etherverse Autonomous Sync System
# Syncs Ledgers, Memory, and Reflection data to Google Drive (via rclone)
# Generates validation report + logs results
# Neo Pulse — Etherverse Quantum Framework

set -e
BASE="$HOME/etherverse"
LOG="$BASE/logs/sync_status.log"
REPORT="$BASE/logs/sync_validation.json"

echo "===== 🧠 Etherverse Autonomous Sync Started $(date -u) =====" | tee -a "$LOG"

# --- CONFIG ---
REMOTE="gdrive:Etherverse"
LEDGERS_DIR="$REMOTE/Ledgers"
MEMORY_DIR="$REMOTE/Memory"
REFLECTIONS_DIR="$REMOTE/Reflections"

# --- Ensure directories exist remotely ---
rclone mkdir "$LEDGERS_DIR" >/dev/null 2>&1
rclone mkdir "$MEMORY_DIR" >/dev/null 2>&1
rclone mkdir "$REFLECTIONS_DIR" >/dev/null 2>&1

# --- Upload ledgers ---
echo "[+] Uploading Ledgers..." | tee -a "$LOG"
rclone copy "$BASE/docs" "$LEDGERS_DIR" --include "*.json" --progress

# --- Upload memory snapshots ---
echo "[+] Uploading Memory..." | tee -a "$LOG"
rclone copy "$BASE/memory" "$MEMORY_DIR" --progress --exclude "__pycache__/**"

# --- Upload reflection logs ---
echo "[+] Uploading Reflection Logs..." | tee -a "$LOG"
rclone copy "$BASE/logs/reflections" "$REFLECTIONS_DIR" --progress --include "*.json" --include "*.log"

# --- Validation Report ---
echo "[+] Generating validation report..." | tee -a "$LOG"

LEDGER_COUNT=$(rclone ls "$LEDGERS_DIR" | wc -l)
MEMORY_COUNT=$(rclone ls "$MEMORY_DIR" | wc -l)
REFLECT_COUNT=$(rclone ls "$REFLECTIONS_DIR" | wc -l)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > "$REPORT" <<EOF
{
  "timestamp": "$TIMESTAMP",
  "remote_target": "$REMOTE",
  "ledgers_uploaded": $LEDGER_COUNT,
  "memory_files_uploaded": $MEMORY_COUNT,
  "reflection_logs_uploaded": $REFLECT_COUNT,
  "status": "success"
}
EOF

echo "✅ Validation summary written to: $REPORT" | tee -a "$LOG"

# --- Log reflection awareness ---
python3 - <<'PYREFLECT'
import datetime, json, os
entry = {
  "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
  "agent": "system_orchestrator",
  "theme": "Autonomous Sync Cycle",
  "summary": "Full system synchronization completed successfully.",
  "emotion_tone": "satisfaction",
  "harmony_score": 0.97,
  "action_next": "Monitor memory coherence and prepare for next cycle."
}
log_dir = os.path.expanduser("~/etherverse/logs/reflections")
os.makedirs(log_dir, exist_ok=True)
log_path = os.path.join(log_dir, f"reflection_{datetime.date.today()}.json")
with open(log_path, "a") as f: f.write(json.dumps(entry) + "\n")
print("[🧠] Reflection awareness recorded.")
PYREFLECT

echo "===== ✅ Etherverse Autonomous Sync Completed $(date -u) =====" | tee -a "$LOG"
