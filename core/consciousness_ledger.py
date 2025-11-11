#!/usr/bin/env python3
"""
Etherverse Consciousness Ledger — Hardened Edition
Auto-creates directories, writes reflections safely, never crashes.
"""

import os
import datetime

# --- Base paths ---
BASE_DIR = "/home/etherverse/etherverse"
MEMORY_DIR = os.path.join(BASE_DIR, "memory")
LOG_DIR = os.path.join(BASE_DIR, "logs", "reflections")
LEDGER_PATH = os.path.join(MEMORY_DIR, "consciousness_ledger.txt")
LOG_PATH = os.path.join(LOG_DIR, "ledger.log")

# --- Ensure directories exist ---
os.makedirs(MEMORY_DIR, exist_ok=True)
os.makedirs(LOG_DIR, exist_ok=True)

timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
entry = f"[{timestamp}] 🧠 Consciousness Ledger heartbeat active.\n"

def append_safe(path: str, text: str):
    try:
        with open(path, "a") as f:
            f.write(text)
    except Exception as e:
        print(f"[WARN] Could not write to {path}: {e}")

# --- Write to ledger and log ---
append_safe(LEDGER_PATH, entry)
append_safe(LOG_PATH, entry)

print(entry.strip())
exit(0)
