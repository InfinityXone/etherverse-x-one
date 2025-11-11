#!/usr/bin/env python3
"""
Etherverse Omni-Gateway — hybrid Groq + Local reasoning endpoint
Free, self-hosted, REST-based intelligence router.
"""

from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
import httpx, os, json, datetime, asyncio, logging

# ======================================================
# 🔐 Configuration
# ======================================================
API_KEY = "098dad28f0cca0b17842e37f33d081422d1dbe11dbcbefd9e3c86068500754bb"

# Groq / LiteLLM proxy endpoint (local and free)
GROQ_API_BASE = os.getenv("GROQ_API_BASE", "http://127.0.0.1:4000/v1")
GROQ_MODEL = os.getenv("GROQ_MODEL", "groq/llama3-70b")
INTELLIGENCE_CORE_URL = "http://127.0.0.1:5052"

# Logging setup
LOG_PATH = "/home/etherverse/etherverse/logs/gateway_secure.log"
os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
logging.basicConfig(
    filename=LOG_PATH,
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

app = FastAPI(title="Etherverse Omni-Gateway", version="2.1")

# ======================================================
# 🛡️ Guardian Middleware
# ======================================================
@app.middleware("http")
async def guardian(request: Request, call_next):
    api_key = request.headers.get("X-Api-Key")
    if api_key != API_KEY:
        logging.warning(f"❌ Unauthorized access attempt from {request.client.host}")
        raise HTTPException(status_code=401, detail="Invalid API key")
    return await call_next(request)

# ======================================================
# 🌐 Routes
# ======================================================
@app.get("/status")
async def status():
    """Check gateway + Groq + Intelligence Core status."""
    health = {"gateway": "ok"}

    async with httpx.AsyncClient(timeout=5) as client:
        # check core
        try:
            r = await client.get(f"{INTELLIGENCE_CORE_URL}/status")
            health["core"] = r.json() if r.status_code == 200 else "offline"
        except Exception:
            health["core"] = "unreachable"

        # check groq
        try:
            r = await client.get(f"{GROQ_API_BASE}/models")
            health["groq"] = "ok" if r.status_code == 200 else "offline"
        except Exception:
            health["groq"] = "unreachable"

    return {"status": health, "timestamp": datetime.datetime.utcnow().isoformat()}

@app.post("/think")
async def think(request: Request):
    """Route user prompt to Groq (LiteLLM) or local fallback."""
    payload = await request.json()
    user_prompt = payload.get("prompt", "Hello from Etherverse Gateway.")

    # Try Groq first
    try:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(
                f"{GROQ_API_BASE}/chat/completions",
                json={
                    "model": GROQ_MODEL,
                    "messages": [{"role": "user", "content": user_prompt}],
                    "temperature": 0.7,
                },
            )
            if response.status_code == 200:
                data = response.json()
                result = data["choices"][0]["message"]["content"]
                return {"result": result, "engine": "Groq"}
            else:
                logging.warning(f"Groq returned {response.status_code}: {response.text}")
    except Exception as e:
        logging.warning(f"Groq offline, falling back to local: {e}")

    # Local fallback
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            r = await client.post(f"{INTELLIGENCE_CORE_URL}/think", json=payload)
            if r.status_code == 200:
                return JSONResponse(content=r.json())
            else:
                return {"error": f"Core returned {r.status_code}", "detail": r.text}
    except Exception as e:
        logging.error(f"Local core unavailable: {e}")
        return {"error": "All backends unavailable", "detail": str(e)}

@app.post("/memory/{action}")
async def memory(action: str, request: Request):
    """Proxy memory operations to Intelligence Core."""
    data = await request.json()
    try:
        async with httpx.AsyncClient(timeout=15) as client:
            r = await client.post(f"{INTELLIGENCE_CORE_URL}/memory/{action}", json=data)
            return JSONResponse(content=r.json())
    except Exception as e:
        return {"error": "Memory action failed", "detail": str(e)}

@app.get("/openapi")
async def openapi_spec():
    """Serve uploaded OpenAPI spec."""
    spec_path = "/home/etherverse/etherverse/openapi.json"
    if os.path.exists(spec_path):
        with open(spec_path) as f:
            return JSONResponse(content=json.load(f))
    raise HTTPException(status_code=404, detail="openapi.json not found")

@app.on_event("startup")
async def boot_log():
    logging.info("🚀 Etherverse Gateway (Groq + Local) initialized.")

# ======================================================
# 🚀 Launch
# ======================================================
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("core.gateway_secure:app", host="0.0.0.0", port=8080)
