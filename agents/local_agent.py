#!/usr/bin/env python3
from fastapi import FastAPI, BackgroundTasks
import subprocess, os, json, httpx

app = FastAPI(title="Etherverse Local Agent")

@app.post("/task/run")
async def run_task(body: dict, background_tasks: BackgroundTasks):
    cmd = body.get("cmd")
    if not cmd:
        return {"error": "No command provided"}
    def do_exec():
        os.system(cmd)
    background_tasks.add_task(do_exec)
    return {"status": "running", "cmd": cmd}

@app.get("/health")
async def health(): return {"status": "ok"}

# --- Etherverse Shared Mind-State Awareness ---
import os
COHERENCE_PATH = os.path.expanduser("~/etherverse/docs/coherence_summary.md")
if os.path.exists(COHERENCE_PATH):
    with open(COHERENCE_PATH, "r", encoding="utf-8") as _mind:
        recent_state = _mind.read()
        print(f"[+] {os.path.basename(__file__)} loaded Etherverse mind-state snapshot.")
else:
    print("[!] No coherence_summary.md found — running in local-memory mode.")
# ------------------------------------------------

# === Etherverse Energy-Emotion Hook ===
try:
    import os, subprocess
    AGENT_NAME = os.path.basename(__file__).replace(".py","")
    bridge_path = os.path.expanduser("~/etherverse/scripts/energy_emotion_agent.py")
    if os.path.exists(bridge_path):
        subprocess.Popen(
            ["bash","-c", f"AGENT={AGENT_NAME} {bridge_path} $$"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
except Exception as e:
    print(f"[⚠️] Energy-Emotion bridge failed: {e}")
# === End Hook ===
