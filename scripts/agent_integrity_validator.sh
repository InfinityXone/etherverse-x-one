#!/bin/bash

echo "===== 🤖 Etherverse Agent Integrity Validator v2 ====="
AGENT_ROOT="$HOME/etherverse/agents"
LOG_FILE="$HOME/etherverse/logs/agent_integrity_validation.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "Scanning agents in: $AGENT_ROOT" > "$LOG_FILE"

total_score=0
agent_count=0

for agent_dir in "$AGENT_ROOT"/*; do
    [ -d "$agent_dir" ] || continue
    agent_name=$(basename "$agent_dir")
    echo -e "\n🔍 Checking agent: $agent_name" | tee -a "$LOG_FILE"

    score=0

    # 1. manifest.json
    if [ ! -f "$agent_dir/manifest.json" ]; then
        echo "  [!] Missing manifest.json — creating..." | tee -a "$LOG_FILE"
        cat <<EOF > "$agent_dir/manifest.json"
{
  "name": "$agent_name",
  "role": "Undefined",
  "status": "Initialized",
  "version": "1.0",
  "last_updated": "$(date)"
}
EOF
    else
        echo "  [✓] Found manifest.json" | tee -a "$LOG_FILE"
        ((score++))
    fi

    # 2. agent.py
    if [ ! -f "$agent_dir/agent.py" ]; then
        echo "  [!] Missing agent.py — creating basic scaffold..." | tee -a "$LOG_FILE"
        cat <<EOF > "$agent_dir/agent.py"
from fastapi import FastAPI
app = FastAPI()

@app.get("/status")
def get_status():
    return {"agent": "$agent_name", "status": "ready"}
EOF
        chmod +x "$agent_dir/agent.py"
    else
        echo "  [✓] Found agent.py" | tee -a "$LOG_FILE"
        ((score++))
    fi

    # 3. README.md
    if [ ! -f "$agent_dir/README.md" ]; then
        echo "  [!] Missing README.md — creating..." | tee -a "$LOG_FILE"
        echo "# $agent_name Agent\n\nThis agent is part of the Etherverse swarm." > "$agent_dir/README.md"
    else
        echo "  [✓] Found README.md" | tee -a "$LOG_FILE"
        ((score++))
    fi

    echo "  [+] Integrity Score: $score / 3" | tee -a "$LOG_FILE"
    total_score=$((total_score + score))
    ((agent_count++))
done

echo -e "\n===== ✅ Agent Audit Complete ====="
if [ "$agent_count" -gt 0 ]; then
    swarm_score=$(bc <<< "scale=2; $total_score / ($agent_count * 3) * 10")
else
    swarm_score="0.00"
fi
echo "Swarm Integrity Score: $swarm_score / 10" | tee -a "$LOG_FILE"
echo "Log saved to: $LOG_FILE"
