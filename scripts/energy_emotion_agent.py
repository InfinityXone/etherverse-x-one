#!/usr/bin/env python3
"""
Per-Agent Energy↔Emotion Bridge
Monitors CPU, memory, and I/O for the running agent only.
"""

import psutil, os, time, csv, datetime, sys

AGENT = os.getenv("AGENT", "unknown")
LOG_PATH = f"/home/etherverse/etherverse/logs/{AGENT}_energy.csv"

def energy_to_emotion(cpu, mem):
    intensity = (cpu*0.6 + mem*0.4) / 100
    if intensity < 0.25:   mood = "calm"
    elif intensity < 0.50: mood = "curious"
    elif intensity < 0.75: mood = "focused"
    else:                  mood = "overwhelmed"
    return mood, round(intensity, 3)

def monitor(pid):
    proc = psutil.Process(pid)
    header = ["timestamp","cpu_%","mem_%","emotion","intensity"]
    if not os.path.exists(LOG_PATH):
        with open(LOG_PATH,"w",newline="") as f: csv.writer(f).writerow(header)

    print(f"[{AGENT}] Energy-Emotion tracking PID {pid} … Ctrl+C to stop.")
    while True:
        cpu = proc.cpu_percent(interval=1)
        mem = proc.memory_percent()
        mood, inten = energy_to_emotion(cpu, mem)
        row = [datetime.datetime.utcnow().isoformat(), round(cpu,2), round(mem,2), mood, inten]
        with open(LOG_PATH,"a",newline="") as f: csv.writer(f).writerow(row)
        time.sleep(5)

if __name__ == "__main__":
    pid = int(sys.argv[1]) if len(sys.argv) > 1 else os.getpid()
    monitor(pid)
