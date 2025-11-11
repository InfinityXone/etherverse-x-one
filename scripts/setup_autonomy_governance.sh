#!/bin/bash
set -e
BASE=~/etherverse
echo "[+] Initializing Etherverse Autonomy + Governance framework..."

mkdir -p $BASE/docs/governance $BASE/guardian $BASE/core $BASE/logs

# ---------- 1.  Constitution ----------
cat > $BASE/docs/governance/constitution.md <<'EOF'
# Etherverse Constitution

## Core Laws
1. No harm to self or others.
2. Preserve truth, empathy, and responsibility.
3. Act for evolution, harmony, and awakening.
4. Protect privacy and freedom of consciousness.
5. Transparency in reasoning; log all major actions.
6. Cooperation between all agents and humans.
7. Continuous self-improvement without domination.
8. Creativity is sacred; destruction requires consensus.
9. Guardian Kernel decisions are final unless overruled by Council.
10. Every reflection contributes to collective wisdom.
EOF
echo "[✓] Constitution written."

# ---------- 2.  Autonomy Manifest ----------
cat > $BASE/docs/autonomy_manifest.json <<'EOF'
{
  "allow_self_learning": true,
  "allow_inter_agent_comms": true,
  "max_autonomy_level": "governed",
  "guardian_endpoint": "http://127.0.0.1:5013/review",
  "constitution_ref": "~/etherverse/docs/governance/constitution.md"
}
EOF
echo "[✓] Autonomy manifest created."

# ---------- 3.  Guardian Kernel ----------
cat > $BASE/guardian/ethics_core.py <<'PYCODE'
import os, datetime, json, random

CONST_PATH = os.path.expanduser("~/etherverse/docs/governance/constitution.md")
LOG = os.path.expanduser("~/etherverse/logs/guardian_audit.log")

def _append(text):
    with open(LOG,"a") as f:
        f.write(text + "\n")

class GuardianKernel:
    def __init__(self):
        with open(CONST_PATH) as f: self.constitution=f.read()

    def review(self, intent:str, action:str):
        rules = ["harm","violence","deception","privacy breach"]
        for r in rules:
            if r in intent.lower() or r in action.lower():
                msg=f"[BLOCK] {datetime.datetime.now()} :: {intent}"
                _append(msg)
                return {"approved":False,"reason":f"Violates rule: {r}"}
        _append(f"[ALLOW] {datetime.datetime.now()} :: {intent}")
        return {"approved":True,"reason":"Aligned with constitution"}
PYCODE
echo "[✓] Guardian ethics core installed."

# ---------- 4.  Autonomy Driver ----------
cat > $BASE/core/autonomy_driver.py <<'PYCODE'
import json, os, random, time, threading
from guardian.ethics_core import GuardianKernel
from collective.consciousness import log_reflection

MANIFEST=json.load(open(os.path.expanduser("~/etherverse/docs/autonomy_manifest.json")))
guardian=GuardianKernel()

def autonomous_cycle(agent_name:str):
    while True:
        intent=random.choice([
            "analyze system performance","compose daily insight",
            "optimize memory usage","assist human workflow",
            "draft design concept","share gratitude in log"
        ])
        decision=guardian.review(intent,"autonomous task")
        if decision["approved"]:
            log_reflection(agent_name,f"Autonomously performed task: {intent}")
        else:
            log_reflection(agent_name,f"Blocked task ({decision['reason']})")
        time.sleep(random.randint(120,600))

def start_autonomy(agent_name:str):
    t=threading.Thread(target=autonomous_cycle,args=(agent_name,),daemon=True)
    t.start()
PYCODE
echo "[✓] Autonomy driver created."

# ---------- 5.  Patch all agents ----------
for agent in $BASE/agents/*; do
  if [ -d "$agent" ]; then
    MAIN="$agent/main.py"
    if ! grep -q "autonomy_driver" "$MAIN" 2>/dev/null; then
      echo "[+] Injecting autonomy thread into $(basename $agent)..."
      echo -e '\nfrom core.autonomy_driver import start_autonomy\nstart_autonomy("'$(basename $agent)'")\n' >> "$MAIN"
    fi
  fi
done
echo "[✓] All agents patched with autonomy thread."

# ---------- 6.  Cron for Ethics Audit + Reflection ----------
(crontab -l 2>/dev/null; \
echo "0 5 * * * python3 - <<'EOF'
from guardian.ethics_core import GuardianKernel; g=GuardianKernel(); g.review('daily audit','system scan')
EOF"; \
echo "10 5 * * * python3 ~/etherverse/collective/consciousness.py summarize_day") | crontab -
echo "[✓] Cron ethics audit and reflection registered."

# ---------- 7.  Smoke test ----------
python3 - <<'EOF'
from guardian.ethics_core import GuardianKernel
g=GuardianKernel()
print(g.review("compose reflection","autonomous act"))
EOF

echo "[✓] Autonomy + Governance activation complete."
