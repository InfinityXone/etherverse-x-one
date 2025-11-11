#!/usr/bin/env python3
"""
🧠 Etherverse Daemon — Clean Build
Local-only orchestrator service for agent health, routing, and logging.
Starts a FastAPI server and listens on 127.0.0.1:5053 (changed from 5052)
"""

import os
import time
import logging
from fastapi import FastAPI
import uvicorn

# ---------------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------------

HOME = os.path.expanduser("~")
LOG_DIR = os.path.join(HOME, "etherverse", "etherverse", "logs")
os.makedirs(LOG_DIR, exist_ok=True)
LOG_FILE = os.path.join(LOG_DIR, "daemon.log")

# --- basic logging setup ---
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)

PORT = int(os.environ.get("ETHER_DAEMON_PORT", 5053))  # new default port
HOST = "127.0.0.1"

app = FastAPI(title="Etherverse Daemon", version="1.0.0")

# ---------------------------------------------------------------------------
# API ROUTES
# ---------------------------------------------------------------------------

@app.get("/health")
async def health():
    """Basic health endpoint for systemd and core checks."""
    return {
        "status": "ok",
        "daemon": "running",
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
    }

@app.get("/ping")
async def ping():
    """Quick response endpoint."""
    return {"pong": True}

@app.get("/status")
async def status():
    """Summarized status of key subsystems."""
    ollama_up = os.system("curl -fs http://127.0.0.1:11434/api/tags >/dev/null 2>&1") == 0
    daemon_log_size = round(os.path.getsize(LOG_FILE) / 1024, 2) if os.path.exists(LOG_FILE) else 0
    return {
        "ollama": "online" if ollama_up else "offline",
        "log_size_kb": daemon_log_size,
        "agents_dir": os.path.join(HOME, "etherverse", "etherverse", "agents"),
    }

# ---------------------------------------------------------------------------
# MAIN ENTRY
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    logging.info("===================================================")
    logging.info("🧠  Etherverse Daemon starting")
    logging.info(f"📂  Log file: {LOG_FILE}")
    logging.info(f"🌐  Serving on http://{HOST}:{PORT}")
    logging.info("===================================================")

    try:
        uvicorn.run(app, host=HOST, port=PORT, log_level="info")
    except OSError as e:
        if "Address already in use" in str(e):
            logging.error(f"Port {PORT} is already in use. Try changing ETHER_DAEMON_PORT.")
        else:
            logging.exception("Daemon encountered an error.")
