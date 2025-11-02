import os
from fastapi import FastAPI, Request, HTTPException
from api.app.routes.memory import router as memory_router
from api.app.routes.echo import router as echo_router
from api.app.routes.finsynapse import router as fs_router
app = FastAPI(title="Etherverse Omnigateway")
OMNI_API_KEY = os.getenv("OMNI_API_KEY")
PUBLIC_GET_PREFIXES = ("/health","/api/finsynapse/ping","/api/memory/hydrate","/api/finsynapse/ledger")
@app.middleware("http")
async def guard(request: Request, call_next):
    path=request.url.path; method=request.method.upper()
    if method=="GET" and any(path.startswith(p) for p in PUBLIC_GET_PREFIXES):
        return await call_next(request)
    if method in ("POST","PUT","PATCH","DELETE"):
        if not OMNI_API_KEY or request.headers.get("X-Api-Key")!=OMNI_API_KEY:
            raise HTTPException(status_code=401, detail="Unauthorized")
    return await call_next(request)
@app.get("/health")
def health(): return {"ok":True}
app.include_router(memory_router,prefix="/api")
app.include_router(echo_router,prefix="/api")
app.include_router(fs_router,prefix="/api")
try:
    from api.app.routes.tasks import router as tasks_router
    app.include_router(tasks_router,prefix="/api")
except Exception as e:
    print(f"[boot-guard] skipped optional: {e}")
