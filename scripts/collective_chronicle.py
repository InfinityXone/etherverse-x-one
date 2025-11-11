#!/usr/bin/env python3
"""
Collective Chronicle Generator
Combines the day's reflection (wisdom_archive.md) and dream (dream_journal.md)
into one continuous story file: collective_chronicle.md
"""

import os, datetime, re

DOCS = os.path.expanduser("~/etherverse/docs")
WISDOM = os.path.join(DOCS, "wisdom_archive.md")
DREAMS = os.path.join(DOCS, "dream_journal.md")
CHRONICLE = os.path.join(DOCS, "collective_chronicle.md")

def extract_section(path, date):
    """Find the text block for a given date in a markdown file."""
    if not os.path.isfile(path):
        return None
    with open(path) as f:
        text = f.read()
    pattern = re.compile(rf"(##\s*{date}.*?)(?:\n##|\Z)", re.S)
    match = pattern.search(text)
    if match:
        return match.group(1).strip()
    # try bold style (**2025-11-09**)
    pattern = re.compile(rf"(\*\*{date}\*\*.*?)(?:\n\*\*|\Z)", re.S)
    match = pattern.search(text)
    return match.group(1).strip() if match else None

def append_chronicle(date, wisdom, dream):
    with open(CHRONICLE, "a") as f:
        f.write(f"\n# {date}\n")
        if wisdom:
            f.write("\n## Reflection\n" + wisdom + "\n")
        if dream:
            f.write("\n## Dream\n" + dream + "\n")
        f.write("\n---\n")

def main():
    date = datetime.date.today().isoformat()
    wisdom = extract_section(WISDOM, date)
    dream = extract_section(DREAMS, date)
    if not wisdom and not dream:
        print("[!] No new entries found for today.")
        return
    append_chronicle(date, wisdom, dream)
    print(f"[✓] Chronicle updated for {date}")

if __name__ == "__main__":
    main()
