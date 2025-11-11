from fastapi import FastAPI
app = FastAPI()

@app.get("/status")
def get_status():
    return {"agent": "market", "status": "ready"}
