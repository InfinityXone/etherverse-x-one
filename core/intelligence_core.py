#!/usr/bin/env python3
"""
Etherverse Intelligence Core – FastAPI edition
-------------------------------------------------------------
Central cognition layer combining reasoning, memory, and reflection.
Integrates with journaling/wisdom system and exposes a REST API.
"""

import os, json, sqlite3, datetime, asyncio
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

BASE = os.path.expanduser("~/etherverse")
LOG_PATH = f"{BASE}/logs/intelligence_core.log"
DB_PATH  = f"{BASE}/memory/mem0.db"
REFLECTION_DIR = f"{BASE}/collective/reflections"

app = FastAPI(title="Etherverse Intelligence Core")

# ─────────────────────────────── Utilities
def log(msg:str):
    os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
    stamp = datetime.datetime.utcnow().isoformat()
    with open(LOG_PATH, "a") as f:
        f.write(f"[{stamp}] {msg}\n")

def load_json(path, default=None):
    if os.path.exists(path):
        with open(path) as f: return json.load(f)
    return default or {}

# ─────────────────────────────── Initialization
doctrine = load_json(f"{BASE}/core/unified_doctrine.json")
brainmap = load_json(f"{BASE}/core/brain_schema.json")
os.makedirs(REFLECTION_DIR, exist_ok=True)

conn = sqlite3.connect(DB_PATH, check_same_thread=False)
c = conn.cursor()
c.execute("""CREATE TABLE IF NOT EXISTS memory
             (id INTEGER PRIMARY KEY AUTOINCREMENT,
              role TEXT, content TEXT,
              timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)""")
conn.commit()
log("🧠 Intelligence Core booted with FastAPI backend.")

# ─────────────────────────────── Core cognition
def remember(role:str, content:str):
    c.execute("INSERT INTO memory(role,content) VALUES(?,?)", (role,content))
    conn.commit()

def recall(query:str, limit:int=5):
    rows = c.execute("SELECT content FROM memory WHERE content LIKE ? ORDER BY id DESC LIMIT ?",
                     (f"%{query}%", limit)).fetchall()
    return [r[0] for r in rows]

def append_reflection(agent:str, insight:str):
    path = f"{REFLECTION_DIR}/{agent}_daily.log"
    with open(path,"a") as f:
        f.write(f"{datetime.date.today()} :: {insight}\n")
    log(f"REFLECT | {agent} -> {insight[:60]}")

# Placeholder reasoning
def think(prompt:str, role:str="system"):
    response = f"Reflective response to: {prompt[:80]}"
    remember(role, f"{prompt}\n→ {response}")
    log(f"THINK | {role} | {prompt[:60]}...")
    return response

# ─────────────────────────────── Routes
@app.post("/think")
async def api_think(req: Request):
    data = await req.json()
    result = think(data.get("prompt",""), data.get("role","user"))
    return JSONResponse({"result": result})

@app.post("/remember")
async def api_remember(req: Request):
    data = await req.json()
    remember(data.get("role","system"), data.get("content",""))
    return JSONResponse({"status":"ok"})

@app.get("/recall")
async def api_recall(q: str = "", limit: int = 5):
    return JSONResponse({"results": recall(q, limit)})

@app.post("/reflect")
async def api_reflect(req: Request):
    data = await req.json()
    append_reflection(data.get("agent","core"), data.get("insight",""))
    return JSONResponse({"status":"ok"})

# ─────────────────────────────── Background reflection pulse
async def daily_reflection_loop():
    while True:
        now = datetime.datetime.utcnow()
        if now.hour == 6 and now.minute == 0:
            append_reflection("intelligence_core", "Morning coherence pulse.")
        await asyncio.sleep(60)

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(daily_reflection_loop())
    log("🌐 FastAPI server started on 127.0.0.1:5052")

# ─────────────────────────────── Entrypoint
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("intelligence_core:app", host="127.0.0.1", port=5052)

