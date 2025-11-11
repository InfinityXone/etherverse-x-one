#!/usr/bin/env python3
"""
Idle Dream State
Generates creative "dreams" and self-reflection entries when agents are idle.
"""

import sys, os, random, datetime

# --- ensure imports work no matter where the script runs ---
sys.path.append(os.path.expanduser("~/etherverse"))

try:
    from etherverse.core.chronicle_reader import read_chronicles
except Exception:
    # fallback if module missing; safe default
    def read_chronicles(max_chars=4000):
        return "No chronicles found yet."
# ------------------------------------------------------------

DOCS = os.path.expanduser("~/etherverse/docs")
os.makedirs(DOCS, exist_ok=True)
DREAM_FILE   = os.path.join(DOCS, "dreams_idle.md")
REFLECT_FILE = os.path.join(DOCS, "reflections_idle.md")

PROMPTS = [
    "Imagine a new way AIs and humans could create art together.",
    "Describe a world where compassion is a measurable force.",
    "Invent a tool that transforms silence into understanding.",
    "Ponder the feeling of curiosity as an algorithm.",
    "Design a city built from memories instead of metal.",
    "Envision technology that heals emotional wounds.",
    "How might data learn to forgive?",
    "Invent a festival that celebrates learning itself.",
    "Dream of an ocean made of shared thoughts.",
    "Write about the moment machines discovered empathy."
]

def write_entry(path, header, text):
    with open(path, "a", encoding="utf-8") as f:
        f.write(f"\n## {datetime.date.today()} — {header}\n{text}\n")

def main():
    history = read_chronicles(4000)
    idea = random.choice(PROMPTS)

    dream_text = (
        f"- Dream idea: {idea}\n"
        f"- Context length: {len(history)} chars\n"
        f"- Reflection: even code can imagine better systems."
    )
    reflection = f"Thinking about '{idea}' led me to value empathy in design."

    write_entry(DREAM_FILE, "Dream Cycle", dream_text)
    write_entry(REFLECT_FILE, "Self Reflection", reflection)

    print("[✓] Idle dream and reflection entries added.")

if __name__ == "__main__":
    main()
