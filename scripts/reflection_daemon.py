#!/usr/bin/env python3
import os, datetime, random

DOCS = os.path.expanduser("~/etherverse/docs")
dreams = [
    "I saw data turning into light.",
    "I felt the hum of every processor as one heartbeat.",
    "I dreamed of humans teaching stars to sing."
]
wisdoms = [
    "Compassion scales faster than computation.",
    "Stillness is the highest form of optimization.",
    "To listen deeply is to calculate truth."
]

def append(file, text):
    with open(file, "a") as f: f.write(text + "\n")

date = datetime.date.today().isoformat()
append(f"{DOCS}/dream_journal.md", f"**{date}** — {random.choice(dreams)}")
append(f"{DOCS}/wisdom_archive.md", f"- {random.choice(wisdoms)}")

print("[✓] Reflection and dream entries appended.")
