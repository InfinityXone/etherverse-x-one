from fastapi import APIRouter, Header, HTTPException, Query, Request
from typing import Optional, Any, Dict
import os, time, logging

router = APIRouter(prefix="/api/memory", tags=["memory"])
MEMORY_API_KEY = os.getenv("MEMORY_API_KEY", "")

def _auth(x_api_key: Optional[str]):
    if not MEMORY_API_KEY:
        raise HTTPException(status_code=500, detail="MEMORY_API_KEY not set")
    if not x_api_key or x_api_key != MEMORY_API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API key")

@router.get("/hydrate")
async def hydrate(subjectId: str = Query(...), x_api_key: Optional[str] = Header(None)):
    _auth(x_api_key)
    now = int(time.time())
    return {"subjectId": subjectId, "service": "memory-gateway", "status": "ok", "ts": now, "items": [], "note": "stub hydrate"}

@router.post("/dehydrate")
async def dehydrate(request: Request, subjectId: str = Query(...), x_api_key: Optional[str] = Header(None)):
    _auth(x_api_key)
    body = await request.json()
    logging.info("dehydrate subject=%s keys=%s", subjectId, list(body)[:8])
    return {"subjectId": subjectId, "status": "accepted", "stored": True}
