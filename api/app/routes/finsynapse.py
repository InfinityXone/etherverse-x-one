from fastapi import APIRouter
from typing import Dict, Any, List
router = APIRouter()
_profit: List[Dict[str, Any]] = []
@router.get("/finsynapse/ping")
def ping():
    return {"ok": True, "agent": "finsynapse"}
@router.post("/finsynapse/profit")
def profit(entry: Dict[str, Any]):
    _profit.append(entry)
    return {"ok": True, "count": len(_profit)}
@router.get("/finsynapse/ledger")
def ledger():
    return {"ok": True, "entries": _profit}
