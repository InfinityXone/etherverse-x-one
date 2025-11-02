from fastapi import APIRouter
from datetime import datetime, timezone
import os, json
try:
    from google.cloud import storage
except Exception:
    storage = None
router = APIRouter()
@router.post("/tasks/snapshot-now")
def snapshot_now():
    bucket = os.getenv("SNAPSHOT_BUCKET","infinity-x-one-swarm-system-memory-raw")
    subj = os.getenv("SNAPSHOT_SUBJECT","neo-pulse")
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    data = {"subjectId": subj, "ts": ts, "note":"manual snapshot"}
    if storage is None:
        return {"ok": False, "error":"gcs not available"}
    c = storage.Client(); b=c.bucket(bucket)
    blob=b.blob(f"rosetta/{subj}/{ts}.json")
    blob.upload_from_string(json.dumps(data),content_type="application/json")
    return {"ok":True,"bucket":bucket,"path":blob.name}
