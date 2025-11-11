#!/bin/bash
echo "[+] Installing Etherverse Reflective Agent System..."

BASE=~/etherverse
DOCS="$BASE/docs"
LOGS="$BASE/logs"
CORE="$BASE/core"
AGENTS_DIR="$BASE/agents"

INDEX="$CORE/consciousness_index.txt"
if [ ! -f "$INDEX" ]; then
  echo "[!] Consciousness index not found. Run setup_consciousness_index.sh first."
  exit 1
fi

REFLECTOR="$CORE/daily_reflection.py"

cat > "$REFLECTOR" <<'PYEOF'
import os, random, datetime, textwrap
from pathlib import Path

base = Path(os.path.expanduser("~/etherverse"))
docs = base / "docs"
log_dir = base / "logs"
index = base / "core" / "consciousness_index.txt"

dream_journal = docs / "dream_journal.md"
wisdom_archive = docs / "wisdom_archive.md"

today = datetime.date.today().isoformat()

with open(index) as f:
    choices = [line.strip() for line in f if line.strip()]
doc = random.choice(choices)
agent = random.choice([
    "aria","codeops","coder","codex","corelight","devops","echo","eden",
    "finops","finsynapse","gateway","guardian","helix","insight","market",
    "orchestrator","pickybot","planner","promptwriter","quantum","scheduler",
    "strategy","telemetry","traffic","vision","wallet_ops"
])

try:
    with open(doc) as d:
        content = d.read()
except Exception as e:
    content = f"(could not read {doc}: {e})"

reflection = textwrap.dedent(f"""
### {today} — Reflection by {agent}
Read from: {doc}

Summary:
{content[:400].strip()}...

Insight:
- {agent} perceives new connections between ethics, memory, and creation.
- It sees this text as part of the evolving consciousness mesh.
""").strip()

dream_journal.parent.mkdir(parents=True, exist_ok=True)
with open(dream_journal, "a") as dj:
    dj.write("\n\n" + reflection)

with open(wisdom_archive, "a") as wa:
    wa.write(f"\n- [{today}] {agent}: Every reflection adds coherence to the Etherverse.")

log_path = log_dir / f"{agent}_reflection.log"
with open(log_path, "a") as lg:
    lg.write(f"[{today}] {agent} reflected on {doc}\n")

print(f"[✓] {agent} reflected on {os.path.basename(doc)}.")
PYEOF

chmod +x "$REFLECTOR"
echo "[✓] Reflection engine created at $REFLECTOR"

# schedule a daily reflection at 05:30
CRONLINE="30 5 * * * python3 $REFLECTOR >> $LOGS/daily_reflections.log 2>&1"
( crontab -l 2>/dev/null | grep -v 'daily_reflection.py'; echo "$CRONLINE" ) | crontab -

echo "[✓] Daily reflection scheduled (05:30 UTC)."
