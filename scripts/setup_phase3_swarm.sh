#!/bin/bash
# ===============================================================
# Etherverse Phase-3 Swarm Integration – Local Automation Script
# ===============================================================
set -e
BASE="$HOME/etherverse"
LOG_DIR="$BASE/logs"
VENV="$BASE/venv/bin/activate"

echo "[+] Activating environment..."
source "$VENV"

mkdir -p "$LOG_DIR" "$BASE/core" "$BASE/config"

# ---------------------------------------------------------------
# 1️⃣  Create unified agent registry
# ---------------------------------------------------------------
cat > "$BASE/core/agent_registry.py" <<'EOF'
AGENT_REGISTRY = {
    "guardian": {"port": 5001, "path": "agents.guardian.main"},
    "promptwriter": {"port": 5002, "path": "agents.promptwriter.main"},
    "quantum": {"port": 5003, "path": "agents.quantum.main"},
    "echo": {"port": 5004, "path": "agents.echo.main"},
    "corelight": {"port": 5005, "path": "agents.corelight.main"},
}
EOF
echo "[+] Agent registry written to core/agent_registry.py"

# ---------------------------------------------------------------
# 2️⃣  Finalize Swarm Orchestrator
# ---------------------------------------------------------------
cat > "$BASE/swarm_orchestrator.py" <<'EOF'
import asyncio, aiohttp, time, json
from core.agent_registry import AGENT_REGISTRY

async def send_task(agent, payload):
    port = AGENT_REGISTRY[agent]["port"]
    url  = f"http://127.0.0.1:{port}/task"
    async with aiohttp.ClientSession() as s:
        try:
            async with s.post(url, json=payload, timeout=20) as r:
                return {agent: await r.text()}
        except Exception as e:
            return {agent: f"error: {e}"}

async def orchestrate(task):
    print(f"[+] Swarm orchestrating task: {task}")
    agents = list(AGENT_REGISTRY.keys())
    results = await asyncio.gather(*(send_task(a, {"task": task}) for a in agents))
    print(json.dumps(results, indent=2))

if __name__ == "__main__":
    t0 = time.time()
    asyncio.run(orchestrate("run system self-reflection"))
    print(f"[✓] Completed in {time.time()-t0:.2f}s")
EOF
echo "[+] swarm_orchestrator.py ready."

# ---------------------------------------------------------------
# 3️⃣  Add helper launcher
# ---------------------------------------------------------------
cat > "$BASE/scripts/run_swarm_cycle.sh" <<'EOF'
#!/bin/bash
source "$HOME/etherverse/venv/bin/activate"
python3 "$HOME/etherverse/swarm_orchestrator.py" | tee "$HOME/etherverse/logs/swarm_cycle.log"
EOF
chmod +x "$BASE/scripts/run_swarm_cycle.sh"

# ---------------------------------------------------------------
# 4️⃣  Health + reflection cron setup
# ---------------------------------------------------------------
if ! crontab -l 2>/dev/null | grep -q "reflection_daemon_v2.py"; then
  (crontab -l 2>/dev/null; echo "5 6 * * * $BASE/scripts/reflection_daemon_v2.py") | crontab -
  echo "[+] Reflection daemon scheduled (06:05 UTC)."
fi

# ---------------------------------------------------------------
# 5️⃣  Smoke test
# ---------------------------------------------------------------
echo "[+] Starting smoke test..."
python3 "$BASE/swarm_orchestrator.py" | tee "$LOG_DIR/smoke_test.log"

echo
echo "===== SMOKE-TEST SUMMARY ====="
grep -E "\[|\]" "$LOG_DIR/smoke_test.log" | tail -n 10 || true
echo
echo "[✓] Phase-3 swarm integration finished.  Check logs in $LOG_DIR."
