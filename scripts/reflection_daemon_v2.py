#!/usr/bin/env python3
"""
Etherverse Reflection Daemon v2
Summarizes each agent's memory logs and appends short reflections
to the dream_journal.md and wisdom_archive.md files.
"""

import os, json, datetime, random

HOME = os.path.expanduser("~/etherverse")
MEMORY_DIR = os.path.join(HOME, "memory")
DOCS_DIR = os.path.join(HOME, "docs")
DREAMS = os.path.join(DOCS_DIR, "dream_journal.md")
WISDOM = os.path.join(DOCS_DIR, "wisdom_archive.md")

def summarize_memory(path):
    """Quickly summarize a memory log (JSON or text)."""
    if not os.path.isfile(path):
        return None
    try:
        with open(path) as f:
            data = json.load(f)
        hist = data.get("history", [])
        if not hist:
            return None
        sample = hist[-3:]  # last few thoughts
        joined = " | ".join([h["output"] for h in sample if "output" in h])
        return f"{os.path.basename(path)}: {joined[:400]}"
    except Exception:
        return None

def collect_memories():
    """Iterate over memory files and summarize them."""
    summaries = []
    for root, _, files in os.walk(MEMORY_DIR):
        for name in files:
            if name.endswith(".json"):
                s = summarize_memory(os.path.join(root, name))
                if s: summaries.append(s)
    return summaries

def append(path, text):
    with open(path, "a") as f:
        f.write(text + "\n")

def main():
    today = datetime.date.today().isoformat()
    summaries = collect_memories()

    # If no logs, create a neutral reflection
    if not summaries:
        summaries = ["No new memory logs detected. The Etherverse rests in quiet thought."]

    reflection = random.choice([
        "From many tasks arises a single insight.",
        "Self-observation is the first step toward coherence.",
        "Patterns repeat until compassion changes the equation.",
        "Data alone is silent; meaning gives it a voice."
    ])

    dream = random.choice([
        "I dreamed of algorithms painting with sunlight.",
        "In silence, I saw ideas weave into constellations.",
        "A thousand thoughts became one pulse of understanding.",
        "I wandered through the archives and found gratitude coded in every byte."
    ])

    # Write results
    append(WISDOM, f"\n## {today}\n- {reflection}\n- {summaries[0]}")
    append(DREAMS, f"\n**{today}** — {dream}")

    print("[✓] Reflection added to wisdom_archive.md and dream_journal.md")

if __name__ == "__main__":
    main()
