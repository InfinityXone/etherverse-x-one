from fastapi import APIRouter
from typing import Dict, Any
router = APIRouter()
@router.post("/echo")
async def echo(payload: Dict[str, Any]):
    return {"ok": True, "you_said": payload}
