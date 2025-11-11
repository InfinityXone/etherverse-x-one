#!/usr/bin/env python3
import os, datetime
from pathlib import Path

base = Path.home() / "etherverse"
docs = base / "docs"
memory = base / "memory"
memory.mkdir(exist_ok=True)

out = memory / f"summary_{datetime.date.today()}.md"
with open(out, "w") as f:
    f.write(f"# Memory Summary {datetime.date.today()}\n\n")
    for name in ["coherence_summary.md", "dreams_idle.md", "reflections_idle.md"]:
        path = docs / name
        if path.exists():
            f.write(f"## {name}\n")
            f.write(path.read_text())
            f.write("\n\n")
print(f"[✓] New long-term memory written: {out}")
