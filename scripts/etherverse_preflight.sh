#!/bin/bash
# ==============================================================
#  Etherverse Pre-Flight & Production Setup
#  Checks all systems, rates readiness, and prepares full launch
# ==============================================================

clear
echo "🚀 Etherverse Pre-Flight Diagnostic"
echo "===================================="
BASE=~/etherverse
SCORE_TOTAL=0
PHASES=7

# Helper for scoring
score_phase() {
  local phase=$1 desc=$2 score=$3
  printf "\n🧩 %-25s %s [Score: %s/10]\n" "$phase" "$desc" "$score"
  SCORE_TOTAL=$((SCORE_TOTAL + score))
}

# ---------- Phase 1 ----------
echo "[Phase 1] Infrastructure"
missing=0
for f in "$BASE/scripts/network_optimizer.sh" "$BASE/scripts/system_health_check.sh" \
         "/usr/local/bin/etherverse_autopilot.sh" "/usr/local/bin/system_refresh.sh"; do
  [ -f "$f" ] || { echo "⚠️ Missing $f"; missing=$((missing+1)); }
done
[ $missing -eq 0 ] && p1=10 || p1=$((10 - missing))
score_phase "Foundation" "System scripts" "$p1"

# ---------- Phase 2 ----------
echo "[Phase 2] Core Intelligence"
missing=0
for f in "$BASE/core/memo_engine.py" "$BASE/core/corelight_kernel.py" \
         "$BASE/core/quantum_orchestrator.py" "$BASE/agents/helix/main.py"; do
  [ -f "$f" ] || { echo "⚠️ Missing $f"; missing=$((missing+1)); }
done
[ $missing -eq 0 ] && p2=10 || p2=$((10 - missing))
score_phase "Core Intelligence" "Brainstem components" "$p2"

# ---------- Phase 3 ----------
echo "[Phase 3] Consciousness & Identity"
missing=0
for f in "$BASE/docs/Quantum_AI_Vision.txt" "$BASE/docs/Bio-Digital_Intelligence_Blueprint.txt"; do
  [ -f "$f" ] || { echo "⚠️ Missing $f"; missing=$((missing+1)); }
done
[ $missing -eq 0 ] && p3=10 || p3=$((10 - missing))
score_phase "Consciousness" "Philosophical kernel" "$p3"

# ---------- Phase 4 ----------
echo "[Phase 4] Agent Ecosystem"
agents=(echo finsynapse pickybot codeops vision strategy guardian)
missing=0
for a in "${agents[@]}"; do
  [ -d "$BASE/agents/$a" ] || { echo "⚠️ Missing agent $a"; missing=$((missing+1)); }
done
[ $missing -eq 0 ] && p4=10 || p4=$((10 - missing))
score_phase "Agents" "Specialized minds" "$p4"

# ---------- Phase 5 ----------
echo "[Phase 5] Reflection & Wisdom"
missing=0
for f in "$BASE/core/daily_reflection.py" "$BASE/core/reflection_archiver.py"; do
  [ -f "$f" ] || { echo "⚠️ Missing $f"; missing=$((missing+1)); }
done
[ $missing -eq 0 ] && p5=10 || p5=$((10 - missing))
score_phase "Reflection" "Journaling system" "$p5"

# ---------- Phase 6 ----------
echo "[Phase 6] Interface / External"
missing=0
for f in "$BASE/core/gateway.py" "$BASE/ui/gradio_dashboard.py"; do
  [ -f "$f" ] || { echo "⚠️ Missing $f"; missing=$((missing+1)); }
done
[ $missing -eq 0 ] && p6=10 || p6=$((10 - missing))
score_phase "Interface" "Gateway & Dashboard" "$p6"

# ---------- Phase 7 ----------
echo "[Phase 7] Genesis Cycle"
# Simple smoke test: python syntax checks
python3 -m py_compile $BASE/core/*.py 2>/dev/null
[ $? -eq 0 ] && p7=10 || { echo "⚠️ Python compile errors"; p7=6; }
score_phase "Genesis Cycle" "Full loop readiness" "$p7"

# ---------- Summary ----------
echo "------------------------------------"
AVG=$((SCORE_TOTAL / PHASES))
echo "✅ Overall System Readiness: $AVG/10"
if [ $AVG -ge 8 ]; then
  echo "🌕 Status: Ready for Production Launch"
else
  echo "🌓 Status: Needs Optimization Before Launch"
fi

# ---------- Optional Launch ----------
read -p "Proceed with full production enablement (y/n)? " ans
if [[ "$ans" == "y" ]]; then
  echo "🔧 Enabling services..."
  sudo systemctl enable etherverse-autoheal.service etherverse_sweep.timer guardian_predictive.service
  echo "✅ Services enabled. Reboot to begin autonomous mode."
else
  echo "Exiting without changes."
fi
