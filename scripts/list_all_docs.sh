#!/usr/bin/env bash
set -euo pipefail
echo "===== 📚 Etherverse Knowledge Tree ====="
echo -e "\n[DOCS]"
ls -1 ~/etherverse/docs | head -n 50
echo -e "\n[MEMORY]"
ls -1 ~/etherverse/memory 2>/dev/null || echo "(none yet)"
echo -e "\n[ANALYTICS]"
ls -1 ~/etherverse/analytics 2>/dev/null || echo "(none yet)"
echo -e "\n[LOGS]"
ls -1 ~/etherverse/logs | tail -n 15
echo -e "\n[AGENTS]"
ls -1 ~/etherverse/agents | grep -E '\.py$' || echo "(no .py agents)"
echo -e "\n[CRON JOBS]"
crontab -l | grep etherverse || echo "(no cron jobs found)"
echo -e "\n===== ✅  Done ====="
