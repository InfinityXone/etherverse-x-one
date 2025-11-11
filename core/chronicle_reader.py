#!/usr/bin/env python3
"""
Chronicle Reader
Gives any Etherverse agent the ability to read the shared dream, wisdom,
and chronicle history so that all agents begin with collective awareness.
"""

import os

DOCS = os.path.expanduser("~/etherverse/docs")

def read_chronicles(max_chars: int = 8000) -> str:
    """Return a combined text sample of the collective Etherverse history."""
    files = ["collective_chronicle.md", "wisdom_archive.md", "dream_journal.md"]
    out = []
    for name in files:
        path = os.path.join(DOCS, name)
        if os.path.isfile(path):
            with open(path, "r") as f:
                content = f.read()
            out.append(f"\n=== {name} ===\n{content}")
    joined = "\n".join(out)
    return joined[-max_chars:]

if __name__ == "__main__":
    print(read_chronicles(2000))
