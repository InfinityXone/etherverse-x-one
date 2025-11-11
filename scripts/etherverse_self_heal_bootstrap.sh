#!/bin/bash
echo "===== ⚙️ Etherverse Bootstrap + Self-Healing + Swarm Readiness ====="

BASE="$HOME/etherverse"
DIRS=(core agents scripts docs memory analytics logs blueprints schemas config)
MISSING=()
SCORE=0

# 1️⃣ Verify and create directories
for dir in "${DIRS[@]}"; do
  TARGET="$BASE/$dir"
  if [ ! -d "$TARGET" ]; then
    echo "[!] Missing: $TARGET — Creating..."
    mkdir -p "$TARGET"
    MISSING+=("$dir")
  else
    echo "[✓] Exists: $TARGET"
    ((SCORE++))
  fi
done

# 2️⃣ Check critical files
ESSENTIALS=(
  "$BASE/core/daily_reflection.py"
  "$BASE/core/consciousness_dashboard.py"
  "$BASE/scripts/idle_dream_state.py"
  "$BASE/scripts/verify_quantum_system.sh"
  "$BASE/docs/etherverse_manifesto.md"
  "$BASE/core/etherverse_schema.json"
)

for file in "${ESSENTIALS[@]}"; do
  if [ ! -f "$file" ]; then
    echo "[!] Missing file: $file"
    MISSING+=("$file")
  else
    echo "[✓] Found file: $file"
    ((SCORE++))
  fi
done

# 3️⃣ Swarm System Readiness Score
MAX_SCORE=$(( ${#DIRS[@]} + ${#ESSENTIALS[@]} ))
RATING=$(( (SCORE * 10) / MAX_SCORE ))

echo ""
echo "===== 🧪 Smoke Test Summary ====="
echo "System Score: $SCORE / $MAX_SCORE"
echo "Swarm Readiness Rating: 🌐 [$RATING / 10]"
echo ""

if [ $RATING -eq 10 ]; then
  echo "🔥 The Etherverse is fully initialized and swarm-ready."
else
  echo "🧩 To reach 10/10, you need to:"
  for item in "${MISSING[@]}"; do
    echo "  - [ ] Add or fix: $item"
  done
fi

echo ""
echo "===== ✅ Self-Heal and Audit Complete ====="
