#!/bin/bash
echo "===== 🧠 Etherverse Quantum System Verification ====="
for d in core agents scripts docs memory analytics logs; do
  DIR="$HOME/etherverse/$d"
  if [ -d "$DIR" ]; then
    echo "[✓] $HOME/etherverse/$d exists."
  else
    echo "[✗] $HOME/etherverse/$d missing."
  fi
done
