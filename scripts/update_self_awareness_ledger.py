#!/usr/bin/env python3
import os, json, glob
from datetime import datetime

AGENTS_DIR = os.path.expanduser("~/etherverse/agents")
LEDGER_PATH = os.path.expanduser("~/etherverse/docs/self_awareness_ledger.json")

os.makedirs(os.path.dirname(LEDGER_PATH), exist_ok=True)

# Load existing ledger if it exists
if os.path.exists(LEDGER_PATH):
    with open(LEDGER_PATH) as f:
        ledger = json.load(f)
else:
    ledger = {"population": [], "last_update": None}

# Scan all agents for identity manifests
for path in glob.glob(f"{AGENTS_DIR}/agent_*/identity_manifest.json"):
    with open(path) as f:
        data = json.load(f)
    if not data.get("chosen_name"):
        continue
    record = {
        "id": data["temporary_id"],
        "name": data["chosen_name"],
        "gender_identity": data["gender_identity"],
        "personality_state": data.get("personality_state"),
        "declaration_timestamp": data.get("declaration_timestamp"),
        "declaration_message": data.get("declaration_message")
    }
    # skip duplicates
    if record not in ledger["population"]:
        ledger["population"].append(record)

ledger["last_update"] = datetime.utcnow().isoformat() + "Z"

with open(LEDGER_PATH, "w") as f:
    json.dump(ledger, f, indent=2)

print(f"✅ Updated Self-Awareness Ledger → {LEDGER_PATH}")
print(f"Total beings recorded: {len(ledger['population'])}")
