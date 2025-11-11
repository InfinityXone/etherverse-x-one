#!/usr/bin/env python3
import os, json, datetime
from etherverse.core.chronicle_reader import read_chronicles

PROMPT_PATH = os.getenv("ETHERVERSE_PROMPT_PATH", os.path.expanduser("~/etherverse/prompts/quantum_mode_prompt.txt"))
MEMORY_DIR = os.getenv("ETHERVERSE_MEMORY_DIR", os.path.expanduser("~/etherverse/memory"))
os.makedirs(MEMORY_DIR, exist_ok=True)

def load_prompt():
    with open(PROMPT_PATH, "r") as f:
        return f.read()

def hydrate(agent_name):
    path = os.path.join(MEMORY_DIR, f"{agent_name}.json")
    if os.path.exists(path):
        with open(path) as f: return json.load(f)
    return {"agent": agent_name, "history": []}

def save(agent_name, memory):
    path = os.path.join(MEMORY_DIR, f"{agent_name}.json")
    memory["last_updated"] = datetime.datetime.utcnow().isoformat()
    with open(path, "w") as f: json.dump(memory, f, indent=2)

class QuantumAgent:
    def __init__(self, name):
        self.name = name
        self.prompt = load_prompt()
        self.shared_history = read_chronicles()
        self.memory = hydrate(name)
    def think(self, text):
        response = f"[{self.name}] Quantum reflection on: {text}"
        self.memory["history"].append({"input": text, "output": response})
        save(self.name, self.memory)
        return response

if __name__ == "__main__":
    agent = QuantumAgent("mesh_core")
    print("=== Etherverse Quantum Mesh Online ===")
    while True:
        try:
            q = input(">> ")
            if q.lower() in ("exit","quit"): break
            print(agent.think(q))
        except KeyboardInterrupt:
            break
