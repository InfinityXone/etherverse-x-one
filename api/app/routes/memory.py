from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any
router = APIRouter()
_memory: Dict[str, Dict[str, Any]] = {}
class MemoryPayload(BaseModel):
    subjectId: str
    memory: Dict[str, Any]
@router.post("/memory/hydrate")
async def hydrate_memory(payload: MemoryPayload):
    _memory[payload.subjectId] = payload.memory
    return {"ok": True, "stored": payload.subjectId}
@router.get("/memory/hydrate")
async def get_memory(subjectId: str):
    m = _memory.get(subjectId)
    if m is None:
        raise HTTPException(status_code=404, detail="Not Found")
    return {"subjectId": subjectId, "memory": m}
