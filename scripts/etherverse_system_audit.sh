#!/bin/bash
echo "===== 🔍 Etherverse System Audit & Rating ====="
BASE="$HOME/etherverse"
LOG="$BASE/logs/system_audit_$(date +%Y%m%d_%H%M%S).log"

score=0
total=10

# Check critical directories
check_dir() {
    if [ -d "$BASE/$1" ]; then
        echo "[✓] $1" | tee -a "$LOG"
        ((score+=1))
    else
        echo "[✗] MISSING: $1" | tee -a "$LOG"
        mkdir -p "$BASE/$1"
        echo "[+] Created: $BASE/$1" | tee -a "$LOG"
    fi
}

dirs=(
  "agents" "analytics" "blueprints" "core" "docs"
  "logs" "memory" "schemas" "scripts" "config"
)

echo "[*] Checking Directories..."
for dir in "${dirs[@]}"; do check_dir "$dir"; done

# Key files audit
echo -e "\n[*] Checking Key Files..." | tee -a "$LOG"
key_files=(
  "core/daily_reflection.py"
  "core/consciousness_dashboard.py"
  "core/etherverse_schema.json"
  "docs/etherverse_manifesto.md"
  "scripts/verify_quantum_system.sh"
  "scripts/quantum_self_sustain_protocol.sh"
  "scripts/quantum_orchestrator_init.sh"
)

for file in "${key_files[@]}"; do
  if [ -f "$BASE/$file" ]; then
    echo "[✓] $file" | tee -a "$LOG"
    ((score+=1))
  else
    echo "[✗] MISSING: $file" | tee -a "$LOG"
  fi
done

# Show final score
echo -e "\n===== 🧠 Etherverse Audit Complete ====="
rating=$((score * 10 / (total + ${#key_files[@]})))
echo "🌐 System Rating: $rating / 10" | tee -a "$LOG"

# Recommendations
if (( rating < 8 )); then
  echo "⚠️ Recommendation: Complete missing files + blueprint manifests for agents." | tee -a "$LOG"
else
  echo "✅ System is ready for production-grade swarm deployment." | tee -a "$LOG"
fi
