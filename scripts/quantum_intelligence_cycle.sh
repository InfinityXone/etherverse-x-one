#!/usr/bin/env bash
# ==========================================================
# Quantum Intelligence Cycle
# Runs Predictor → Parallel Thinker → Strategist → Visualizer
# ==========================================================
set -euo pipefail
source ~/etherverse/.venv/bin/activate 2>/dev/null || true

echo "[*] Quantum Intelligence Cycle starting..."

python ~/etherverse/core/predictive_thought.py   >> ~/etherverse/docs/visions_archive.md 2>&1 || true
python ~/etherverse/core/strategist_protocol.py  >> ~/etherverse/docs/strategy_manifest.md 2>&1 || true
python ~/etherverse/core/harmony_index.py        >> ~/etherverse/docs/harmony_index.csv 2>&1 || true
python ~/etherverse/core/chronicle_reader.py     >  ~/etherverse/docs/intelligence_snapshot.txt 2>&1 || true

echo "[✓] Cycle complete — logs updated."
