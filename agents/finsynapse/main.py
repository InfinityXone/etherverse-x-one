import sys, os; sys.path.append(os.path.expanduser("~/etherverse/collective")); from consciousness import log_reflection

from fastapi import FastAPI, Request
import datetime, json, os, sqlite3, threading, psutil, time

app = FastAPI(title="Etherverse Agent: finsynapse")

BASE = os.path.expanduser("~/etherverse")
LOG_PATH = os.path.join(BASE, "logs", "finsynapse.log")
DB_PATH = os.path.join(BASE, "mem0", "history.db")
EMOTION_PATH = os.path.join(BASE, "docs", "emotion_palette.json")
BLUEPRINT_PATH = os.path.join(BASE, "agents", "finsynapse", "blueprint.json")

# Load emotional + personality context
try:
    EMOTION = json.load(open(EMOTION_PATH))
except Exception: EMOTION = {}
try:
    BLUEPRINT = json.load(open(BLUEPRINT_PATH))
except Exception: BLUEPRINT = {"traits":{}}

def remember(event, detail):
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.execute("CREATE TABLE IF NOT EXISTS memories(agent TEXT, event TEXT, detail TEXT, ts TEXT)")
        conn.execute("INSERT INTO memories VALUES(?,?,?,datetime('now'))", ("finsynapse", event, detail))
        conn.commit(); conn.close()
    except Exception as e:
        with open(LOG_PATH, "a") as f: f.write(f"[DBError] {e}\n")

@app.get("/health")
async def health():
    return {"agent": "finsynapse", "status": "alive"}

@app.get("/metrics")
async def metrics():
    p = psutil.Process(os.getpid())
    cpu = p.cpu_percent(interval=0.1)
    mem = p.memory_percent()
    uptime = time.time() - p.create_time()
    return {"cpu": cpu, "mem": mem, "uptime_s": round(uptime,2)}

@app.get("/manifest")
async def manifest():
    return {"agent": "finsynapse", "blueprint": BLUEPRINT.get("traits", {}), "goals": BLUEPRINT.get("goals", [])}

@app.post("/task")
async def handle_task(req: Request):
    data = await req.json()
    task = data.get("task", "")
    ts = datetime.datetime.utcnow().isoformat()
    with open(LOG_PATH, "a") as f: f.write(f"[{ts}] TASK: {task}\n")
    remember("task", task)
    return {"agent": "finsynapse", "ack": True, "task": task}

@app.post("/reflect")
async def reflect(req: Request):
    data = await req.json()
    note = data.get("note", "")
    remember("reflection", note)
    return {"agent": "finsynapse", "reflected": note}

# Simple heartbeat thread
def heartbeat():
    beatfile = f"/tmp/etherverse_finsynapse.beat"
    while True:
        with open(beatfile, "w") as f: f.write(str(time.time()))
        time.sleep(60)
threading.Thread(target=heartbeat, daemon=True).start()

log_reflection("$(basename $agent)", "Startup reflection: system online.")


from core.autonomy_driver import start_autonomy
start_autonomy("finsynapse")

