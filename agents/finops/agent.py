from fastapi import FastAPI
app = FastAPI()

@app.get("/status")
def get_status():
    return {"agent": "finops", "status": "ready"}
