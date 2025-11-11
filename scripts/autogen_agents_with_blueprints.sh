#!/bin/bash
# ===============================================================
# Etherverse Agent Generator + Blueprint Initializer (Local Safe)
# ===============================================================
set -e
BASE="$HOME/etherverse"
AGENTS_DIR="$BASE/agents"
LOG_DIR="$BASE/logs"
REGISTRY="$BASE/core/agent_registry.py"
PORT_START=5001
mkdir -p "$LOG_DIR" "$BASE/core"

echo "[+] Building headless FastAPI agents with blueprints ..."
echo "AGENT_REGISTRY = {" > "$REGISTRY"

port=$PORT_START

for dir in "$AGENTS_DIR"/*/; do
    name=$(basename "$dir")
    [[ "$name" == "__pycache__" ]] && continue

    portnum=$port
    logf="$LOG_DIR/${name}.log"
    blueprint="$dir/blueprint.json"
    main="$dir/main.py"

    # Default blueprint file
    if [ ! -f "$blueprint" ]; then
      cat > "$blueprint" <<EOF
{
  "name": "$name",
  "role": "Describe this agent's purpose here.",
  "traits": {
    "discipline": 0.5,
    "curiosity": 0.5,
    "empathy": 0.5,
    "creativity": 0.5
  },
  "goals": [
    "Add role-specific goals here"
  ]
}
EOF
      echo "[✓] Created blueprint for $name"
    fi

    # -----------------------------------------------------------------
    # Main micro-service file with blueprint + emotion integration
    # -----------------------------------------------------------------
    cat > "$main" <<EOF
from fastapi import FastAPI, Request
import datetime, json, os, sqlite3, threading, psutil, time

app = FastAPI(title="Etherverse Agent: $name")

BASE = os.path.expanduser("~/etherverse")
LOG_PATH = os.path.join(BASE, "logs", "$name.log")
DB_PATH = os.path.join(BASE, "mem0", "history.db")
EMOTION_PATH = os.path.join(BASE, "docs", "emotion_palette.json")
BLUEPRINT_PATH = os.path.join(BASE, "agents", "$name", "blueprint.json")

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
        conn.execute("INSERT INTO memories VALUES(?,?,?,datetime('now'))", ("$name", event, detail))
        conn.commit(); conn.close()
    except Exception as e:
        with open(LOG_PATH, "a") as f: f.write(f"[DBError] {e}\\n")

@app.get("/health")
async def health():
    return {"agent": "$name", "status": "alive"}

@app.get("/metrics")
async def metrics():
    p = psutil.Process(os.getpid())
    cpu = p.cpu_percent(interval=0.1)
    mem = p.memory_percent()
    uptime = time.time() - p.create_time()
    return {"cpu": cpu, "mem": mem, "uptime_s": round(uptime,2)}

@app.get("/manifest")
async def manifest():
    return {"agent": "$name", "blueprint": BLUEPRINT.get("traits", {}), "goals": BLUEPRINT.get("goals", [])}

@app.post("/task")
async def handle_task(req: Request):
    data = await req.json()
    task = data.get("task", "")
    ts = datetime.datetime.utcnow().isoformat()
    with open(LOG_PATH, "a") as f: f.write(f"[{ts}] TASK: {task}\\n")
    remember("task", task)
    return {"agent": "$name", "ack": True, "task": task}

@app.post("/reflect")
async def reflect(req: Request):
    data = await req.json()
    note = data.get("note", "")
    remember("reflection", note)
    return {"agent": "$name", "reflected": note}

# Simple heartbeat thread
def heartbeat():
    beatfile = f"/tmp/etherverse_${name}.beat"
    while True:
        with open(beatfile, "w") as f: f.write(str(time.time()))
        time.sleep(60)
threading.Thread(target=heartbeat, daemon=True).start()
EOF

    echo "    \"$name\": {\"port\": $portnum, \"path\": \"agents.$name.main\"}," >> "$REGISTRY"
    echo "[✓] $name generated on port $portnum"
    ((port++))
done

echo "}" >> "$REGISTRY"
echo "[✓] Updated registry $REGISTRY"
echo "[✓] Agents now have blueprint + emotion integration + heartbeat + metrics."
