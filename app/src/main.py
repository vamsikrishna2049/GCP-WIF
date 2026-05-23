from fastapi import FastAPI
from fastapi.responses import JSONResponse
import os
import time

app = FastAPI(title="Cloud Run WIF CI/CD Demo", version="1.0.0")
START_TIME = time.time()


@app.get("/")
def root():
    return {
        "service": os.getenv("SERVICE_NAME", "myapp"),
        "environment": os.getenv("APP_ENV", "unknown"),
        "status": "ok",
    }


@app.get("/healthz")
def healthz():
    return JSONResponse(
        {
            "status": "healthy",
            "uptime_seconds": int(time.time() - START_TIME),
        }
    )


@app.get("/readyz")
def readyz():
    return {"status": "ready"}
