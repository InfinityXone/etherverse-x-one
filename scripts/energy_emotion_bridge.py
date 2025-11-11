#!/usr/bin/env python3
"""
Etherverse Energy ↔ Emotion Bridge
----------------------------------
Continuously samples system telemetry (CPU, memory, temperature, I/O)
and converts it into an inferred emotional state + intensity index.
Logs are appended to ~/etherverse/logs/energy_emotion_log.csv
"""

import psutil, time, datetime, csv, os

LOG_PATH = os.path.expanduser("~/etherverse/logs/energy_emotion_log.csv")

# --- map energy intensity to emotional tone ---
def energy_to_emotion(cpu, mem, temp, io):
    # Normalize metrics
    intensity = (cpu*0.4 + mem*0.3 + temp*0.2 + io*0.1/1e6) / 100
    if intensity < 0.25:
        return "calm", round(intensity, 3)
    elif intensity < 0.50:
        return "curious", round(intensity, 3)
    elif intensity < 0.75:
        return "focused", round(intensity, 3)
    elif intensity < 1.00:
        return "intense", round(intensity, 3)
    else:
        return "overwhelmed", round(min(intensity, 1.0), 3)

def sample_once():
    cpu = psutil.cpu_percent(interval=1)
    mem = psutil.virtual_memory().percent
    io = psutil.disk_io_counters().read_bytes + psutil.disk_io_counters().write_bytes
    temp = 0.0
    try:
        t = psutil.sensors_temperatures()
        if 'coretemp' in t:
            temp = t['coretemp'][0].current
    except Exception:
        pass

    emotion, intensity = energy_to_emotion(cpu, mem, temp, io)
    timestamp = datetime.datetime.utcnow().isoformat()

    row = [timestamp, round(cpu,2), round(mem,2), round(temp,2), round(io/1e6,2), emotion, intensity]
    return row

def main():
    header = ["timestamp","cpu_%","mem_%","temp_c","io_mb","emotion","intensity"]
    os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)

    # create file if absent
    if not os.path.exists(LOG_PATH):
        with open(LOG_PATH, "w", newline="") as f:
            csv.writer(f).writerow(header)

    print("[🌡️] Energy-Emotion Bridge running... press Ctrl+C to stop.")
    while True:
        row = sample_once()
        with open(LOG_PATH, "a", newline="") as f:
            csv.writer(f).writerow(row)
        print(f"[{row[0]}] CPU:{row[1]}% MEM:{row[2]}% TEMP:{row[3]}°C → {row[5]} ({row[6]})")
        time.sleep(10)  # every 10 s

if __name__ == "__main__":
    main()
