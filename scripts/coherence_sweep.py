#!/usr/bin/env python3
import os, datetime
from pathlib import Path

base = Path.home() / "etherverse"
docs = base / "docs"

files = ["dreams_idle.md", "reflections_idle.md", "collective_chronicle.md"]
output = docs / "coherence_summary.md"

with open(output, "a") as out:
    out.write(f"\n# {datetime.date.today()} — Coherence Summary\n")
    for f in files:
        p = docs / f
        if p.exists():
            out.write(f"\n## {p.name}\n")
            out.write(p.read_text())
            out.write("\n")
print("[✓] Coherence summary updated.")
