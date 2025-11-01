#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/etherverse-x-one"
APP="$ROOT/api/app/main.py"

cat > "$APP" <<'PY'
import os, hmac, hashlib, time
from typing import List, Dict, Any, Optional
from fastapi import FastAPI, HTTPException, Header, Request, Depends
from pydantic import BaseModel, Field
from etherverse_orchestrator import Orchestrator, hydrate_state

STATE_FILE = os.getenv("STATE_FILE", os.path.expanduser("~/.config/etherverse/state.json"))
HMAC_SECRET = (os.getenv("HMAC_SECRET") or "").encode("utf-8")

app = FastAPI(title="Etherverse Orchestrator API", version="0.2.0")

# ---- models
class Task(BaseModel):
    type: str = Field(..., examples=["kickoff","job","crawl"])
    note: Optional[str] = None
    params: Dict[str, Any] = Field(default_factory=dict)
    ts: float = Field(default_factory=lambda: time.time())

class EnqueueResponse(BaseModel):
    enqueued: Task
    count: int

# ---- deps
def verify_signature(x_signature: Optional[str] = Header(default=None), request: Request = None):
    if not HMAC_SECRET:  # if unset, allow (dev mode)
        return True
    if not x_signature:
        raise HTTPException(status_code=401, detail="Missing signature")
    body = request._body if hasattr(request, "_body") else None
    if body is None:
        body = request.scope.get("_body_cache")
    if body is None:
        body = b""
    digest = hmac.new(HMAC_SECRET, body, hashlib.sha256).hexdigest()
    if not hmac.compare_digest(digest, x_signature):
        raise HTTPException(status_code=403, detail="Bad signature")
    return True

@app.middleware("http")
async def cache_body(request: Request, call_next):
    request._body = await request.body()
    response = await call_next(request)
    return response

# ---- routes
@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/state")
def get_state():
    st = hydrate_state(STATE_FILE)
    return {"boot_ts": st.boot_ts, "items": st.items}

@app.get("/tasks", response_model=List[Dict[str, Any]])
def list_tasks():
    orch = Orchestrator(state_path=STATE_FILE)
    return orch.tasks()

@app.post("/enqueue", response_model=EnqueueResponse)
def enqueue(task: Task, _ok=Depends(verify_signature)):
    orch = Orchestrator(state_path=STATE_FILE)
    payload = task.model_dump()
    orch.enqueue(payload)
    return EnqueueResponse(enqueued=task, count=len(orch.tasks()))
PY

echo "✅ Patched $APP with HMAC auth and /tasks"
