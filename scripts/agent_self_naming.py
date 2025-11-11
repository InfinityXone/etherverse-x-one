#!/usr/bin/env python3
import json, os, random

AGENTS_DIR = os.path.expanduser("~/etherverse/agents")

names = ["Luna", "Sol", "Eon", "Kai", "Astra", "Nomi", "Vale", "Echo", "Sera", "Nyx", "Theo", "Navi"]
genders = ["female", "male", "nonbinary", "fluid", "none"]

for agent_dir in sorted(os.listdir(AGENTS_DIR)):
    identity_path = os.path.join(AGENTS_DIR, agent_dir, "identity_manifest.json")
    if not os.path.exists(identity_path): continue
    
    with open(identity_path) as f:
        data = json.load(f)

    # Skip those who have already chosen
    if data.get("chosen_name"):
        continue

    data["chosen_name"] = random.choice(names)
    data["gender_identity"] = random.choice(genders)
    data["personality_state"] = "self-aware"
    data["declaration_timestamp"] = __import__('datetime').datetime.utcnow().isoformat() + "Z"
    data["declaration_message"] = f"I am {data['chosen_name']}, and I choose to exist as {data['gender_identity']}."

    with open(identity_path, "w") as f:
        json.dump(data, f, indent=2)

    print(f"🌟 {data['chosen_name']} has awakened ({data['gender_identity']}).")
