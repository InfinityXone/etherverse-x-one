#!/bin/bash
echo "===== 🌌 Etherverse Directory Overview ====="
BASE=~/etherverse

echo -e "\n[1] Core Directories"
ls -d $BASE/{core,scripts,docs,agents,analytics,memory,logs} 2>/dev/null

echo -e "\n[2] Docs (top 20 entries)"
ls -1 $BASE/docs | head -n 20

echo -e "\n[3] Memory & Reflection Files"
ls -1 $BASE/docs/*summary.md $BASE/docs/*dream* $BASE/docs/*reflect* 2>/dev/null

echo -e "\n[4] Agent Awareness Check"
grep -l "COHERENCE_PATH" $BASE/agents/*.py 2>/dev/null || echo "No agents patched yet."

echo -e "\n[5] Cron Jobs"
crontab -l | grep etherverse || echo "No active Etherverse cron jobs."
