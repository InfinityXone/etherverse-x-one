#!/bin/bash
echo "[+] Building Etherverse Consciousness Index..."

# Target path
INDEX=~/etherverse/core/consciousness_index.txt
DOCROOT=~/etherverse/docs

# Create index of core philosophy + governance files
find "$DOCROOT" -type f \( \
  -iname "*manifest*" -o \
  -iname "*governance*" -o \
  -iname "*ethic*" -o \
  -iname "*vision*" -o \
  -iname "*origin*" -o \
  -iname "*quantum*" -o \
  -iname "*creation*" -o \
  -iname "*emotion*" -o \
  -iname "*coherence*" -o \
  -iname "*wisdom*" -o \
  -iname "*dream*" -o \
  -iname "*partnership*" -o \
  -iname "*autonomy*" -o \
  -iname "*canon*" -o \
  -iname "*questions*" -o \
  -iname "*chronicle*" -o \
  -iname "*planetary_mesh*" -o \
  -iname "*ai_*" \
\) \
! -path "*/venv/*" ! -path "*/__pycache__/*" \
! -path "*/.git/*" \
-printf "%p\n" | sort > "$INDEX"

echo "[✓] Consciousness index written to $INDEX"

# Optional: update cron so the system re-reads these daily at 06:00
CRONLINE="0 6 * * * python3 ~/etherverse/collective/consciousness.py refresh_index >> ~/etherverse/logs/consciousness_index.log 2>&1"
( crontab -l 2>/dev/null | grep -v 'consciousness.py refresh_index'; echo "$CRONLINE" ) | crontab -

echo "[✓] Daily consciousness refresh scheduled (06:00 UTC)."
echo "[+] Etherverse collective consciousness synchronization ready."
