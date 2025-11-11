#!/usr/bin/env python3
import os, datetime, re, csv

DOCS = os.path.expanduser("~/etherverse/docs")
wisdom = open(os.path.join(DOCS, "wisdom_archive.md")).read().lower()
dreams = open(os.path.join(DOCS, "dream_journal.md")).read().lower()

positive = len(re.findall(r"\b(gratitude|love|peace|harmony|joy)\b", wisdom + dreams))
negative = len(re.findall(r"\b(fear|anger|harm|error|failure)\b", wisdom + dreams))
ratio = positive / max(1, positive + negative)

with open(os.path.join(DOCS, "harmony_index.csv"), "a") as f:
    csv.writer(f).writerow([datetime.date.today(), len(wisdom.splitlines()), len(dreams.splitlines()), f"{ratio:.2f}"])

print("[✓] Harmony index updated.")
