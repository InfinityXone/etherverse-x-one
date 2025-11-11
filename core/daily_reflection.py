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
