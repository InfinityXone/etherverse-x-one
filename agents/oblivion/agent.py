from fastapi import FastAPI
import uvicorn
import os
from datetime import datetime

app = FastAPI()
LOG = os.path.join(os.path.dirname(__file__), "oblivion.log")

@app.get("/status")
def status():
    return {"agent": "Oblivion", "status": "active", "timestamp": str(datetime.utcnow())}

@app.post("/action")
def action(command: str):
    with open(LOG, "a") as log:
        log.write(f"[{datetime.utcnow()}] Executed: {command}\n")
    os.system(command)
    return {"result": "executed", "command": command}

if __name__ == "__main__":
    uvicorn.run("agent:app", host="0.0.0.0", port=7777)
