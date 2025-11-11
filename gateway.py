from fastapi import FastAPI, Request
import uvicorn, json, os, subprocess, datetime

app = FastAPI(title="Etherverse Gateway")

@app.get("/health")
async def health():
    return {"status":"alive", "time": str(datetime.datetime.utcnow())}

@app.post("/task")
async def task(req: Request):
    payload = await req.json()
    # This is a light placeholder. Agents should implement business logic.
    # Log the received payload and return an ack.
    with open(os.path.expanduser("~/etherverse/logs/gateway_tasks.log"), "a") as f:
        f.write(f"{datetime.datetime.utcnow().isoformat()} | {json.dumps(payload)}\n")
    return {"ok": True, "received": payload}

if __name__ == "__main__":
    uvicorn.run("gateway:app", host="0.0.0.0", port=int(os.getenv("GATEWAY_PORT", "8080")))
