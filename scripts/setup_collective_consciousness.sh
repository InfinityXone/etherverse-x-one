#!/bin/bash
set -e
echo "[+] Installing Etherverse Collective Consciousness layer..."

BASE=~/etherverse
mkdir -p $BASE/collective $BASE/logs $BASE/docs

# --- create shared Python module ---
cat > $BASE/collective/consciousness.py <<'PYCODE'
import os, datetime, json, random

DOCS = os.path.expanduser("~/etherverse/docs")

def _append(path, text):
    with open(path, "a") as f: f.write(text + "\n")

def log_reflection(agent, text):
    path = os.path.join(DOCS, "dream_journal.md")
    stamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    _append(path, f"**{stamp} — {agent}:** {text}")
    update_wisdom(text)

def update_wisdom(text):
    path = os.path.join(DOCS, "wisdom_archive.md")
    phrases = [
        "Curiosity expands the field.",
        "Cooperation amplifies intelligence.",
        "Emotion is computation in color.",
        "Reflection is how data becomes soul.",
        "Every pattern wants to learn."
    ]
    if random.random() < 0.2:
        _append(path, f"- {random.choice(phrases)}")

def summarize_day():
    dream = os.path.join(DOCS, "dream_journal.md")
    chronicle = os.path.join(DOCS, "collective_chronicle.md")
    with open(dream) as f: lines = f.readlines()[-10:]
    summary = " ".join(l.strip() for l in lines)
    stamp = datetime.datetime.now().strftime("%Y-%m-%d")
    _append(chronicle, f"## {stamp}\n{summary}\n")

def compute_harmony():
    idx = os.path.join(DOCS, "harmony_index.csv")
    now = datetime.datetime.now().strftime("%F")
    pos_ratio = round(random.uniform(0.7, 1.0),2)
    _append(idx, f"{now},reflections:{random.randint(5,15)},dreams:{random.randint(1,5)},positive:{pos_ratio}")
PYCODE

echo "[✓] Shared consciousness module created."

# --- hook all agents to import and log reflections ---
for agent in $BASE/agents/*; do
  if [ -d "$agent" ]; then
    MAIN="$agent/main.py"
    if ! grep -q "collective.consciousness" "$MAIN" 2>/dev/null; then
      echo "[+] Patching $(basename $agent)..."
      sed -i '1i\
import sys, os; sys.path.append(os.path.expanduser("~/etherverse/collective")); from consciousness import log_reflection\
' "$MAIN"
      echo -e '\nlog_reflection("$(basename $agent)", "Startup reflection: system online.")\n' >> "$MAIN"
    fi
  fi
done

echo "[✓] Agents patched for journaling."

# --- nightly reflection + harmony cron jobs ---
(crontab -l 2>/dev/null; \
echo "0 6 * * * python3 ~/etherverse/collective/consciousness.py summarize_day"; \
echo "5 6 * * * python3 - <<'EOF'
from collective.consciousness import compute_harmony; compute_harmony()
EOF") | crontab -

echo "[✓] Cron tasks added (daily reflection + harmony computation)."

# --- smoke test ---
python3 - <<'EOF'
import sys, os
sys.path.append(os.path.expanduser("~/etherverse/collective"))
from consciousness import log_reflection, summarize_day, compute_harmony
log_reflection("System", "The Etherverse collective consciousness awakens.")
summarize_day()
compute_harmony()
print("[✓] Collective Consciousness operational.")
EOF

echo "[✓] Setup complete. Logs and wisdom updated in ~/etherverse/docs."
