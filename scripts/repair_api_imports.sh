#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/etherverse-x-one"
API="$ROOT/api/app"
PKG="$ROOT/etherverse_orchestrator"
REQ="$ROOT/requirements.txt"
STATE="$HOME/.config/etherverse/state.json"

mkdir -p "$API" "$PKG" "$(dirname "$STATE")"

# -- ensure orchestrator package (idempotent)
if [ ! -f "$PKG/__init__.py" ]; then
  cat > "$PKG/__init__.py" <<'PY'
from .orchestrator import Orchestrator
from .hydration import hydrate_state, dehydrate_state, State
__all__ = ["Orchestrator", "hydrate_state", "dehydrate_state", "State"]
PY
fi

if [ ! -f "$PKG/hydration.py" ]; then
  cat > "$PKG/hydration.py" <<'PY'
import json, os, time
from dataclasses import dataclass, asdict
from typing import Any, Dict, List
DEFAULT_STATE_PATH = os.path.expanduser("~/.config/etherverse/state.json")
@dataclass
class State:
    boot_ts: float
    items: List[Dict[str, Any]]
def hydrate_state(path: str = DEFAULT_STATE_PATH) -> "State":
    if not os.path.exists(path):
        return State(boot_ts=time.time(), items=[])
    try:
        with open(path, "r", encoding="utf-8") as f:
            raw = json.load(f)
        return State(**raw)
    except Exception:
        return State(boot_ts=time.time(), items=[])
def dehydrate_state(state: "State", path: str = DEFAULT_STATE_PATH) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(asdict(state), f, indent=2, sort_keys=True)
PY
fi

if [ ! -f "$PKG/orchestrator.py" ]; then
  cat > "$PKG/orchestrator.py" <<'PY'
from typing import List, Dict, Any
from .hydration import State, hydrate_state, dehydrate_state
class Orchestrator:
    def __init__(self, state_path=None):
        self.state_path = state_path
        self.state: State = hydrate_state(state_path)
    def tasks(self) -> List[Dict[str, Any]]:
        return list(self.state.items)
    def enqueue(self, payload: Dict[str, Any]) -> None:
        self.state.items.append(payload)
        dehydrate_state(self.state, self.state_path)
    def summary(self) -> str:
        return f"{len(self.state.items)} task(s) tracked"
PY
fi

# -- ensure FastAPI app
if [ ! -f "$API/main.py" ]; then
  cat > "$API/main.py" <<'PY'
import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from etherverse_orchestrator import Orchestrator, hydrate_state
STATE_FILE = os.getenv("STATE_FILE", os.path.expanduser("~/.config/etherverse/state.json"))
app = FastAPI(title="Etherverse Orchestrator API", version="0.1.0")
class Kickoff(BaseModel):
    note: str
@app.get("/health")
def health():
    return {"status": "ok"}
@app.get("/state")
def get_state():
    st = hydrate_state(STATE_FILE)
    return {"boot_ts": st.boot_ts, "items": st.items}
@app.post("/enqueue")
def enqueue(k: Kickoff):
    try:
        orch = Orchestrator(state_path=STATE_FILE)
        payload = {"type": "kickoff", "note": k.note}
        orch.enqueue(payload)
        return {"enqueued": payload, "count": len(orch.tasks())}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
PY
fi

# -- requirements (leave existing if present)
if [ ! -f "$REQ" ]; then
  cat > "$REQ" <<'REQ'
fastapi
uvicorn
pydantic
REQ
fi

# -- ensure state file
[ -f "$STATE" ] || echo '{ "boot_ts": 0, "items": [] }' > "$STATE"

# -- fix local runner: cd to repo root and use venv python
cat > "$ROOT/scripts/run_api_local.sh" <<'BASH2'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/etherverse-x-one"
PYBIN="$ROOT/.venv/bin/python"
export STATE_FILE="${STATE_FILE:-$HOME/.config/etherverse/state.json}"
if [ ! -x "$PYBIN" ]; then
  echo "Python venv not found. Run: $HOME/etherverse-x-one/scripts/bootstrap_runtime.sh"
  exit 1
fi
cd "$ROOT"
exec "$PYBIN" -m uvicorn api.app.main:app --host 0.0.0.0 --port 8080
BASH2
chmod +x "$ROOT/scripts/run_api_local.sh"

echo "✅ api/app/main.py ensured"
echo "✅ etherverse_orchestrator package ensured"
echo "✅ run_api_local.sh now cds to repo root before starting uvicorn"
