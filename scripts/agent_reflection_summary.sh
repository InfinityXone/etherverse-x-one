#!/bin/bash
# ==========================================
# 🌌 Etherverse Agent Reflection Summary
# ==========================================

REFLECTION_DIR="$HOME/etherverse/logs/reflections"
TODAY=$(date +%F)
LATEST_FILES=$(ls -1 "$REFLECTION_DIR"/*_"$TODAY".json 2>/dev/null)

if [ -z "$LATEST_FILES" ]; then
  echo "[!] No reflection logs found for $TODAY."
  echo "Try running: python3 ~/etherverse/core/reflection_archiver.py"
  exit 1
fi

echo "===== 🧠 Etherverse Agent Reflection Summary ($TODAY) ====="
printf "%-15s %-10s %-10s %-8s %s\n" "Agent" "Tone" "Harmony" "Score" "Summary"
echo "--------------------------------------------------------------------------"

for f in $LATEST_FILES; do
  agent=$(jq -r '.agent' "$f")
  tone=$(jq -r '.emotion_tone' "$f")
  harmony=$(jq -r '.harmony_score' "$f")
  summary=$(jq -r '.summary' "$f")
  printf "%-15s %-10s %-10s %-8s %s\n" "$agent" "$tone" "$harmony" "✓" "$summary"
done

echo "--------------------------------------------------------------------------"
echo "[✓] Total agents reflected: $(echo "$LATEST_FILES" | wc -l)"
