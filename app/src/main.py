import os
from datetime import datetime, timezone

from fastapi import FastAPI


APP_NAME = os.getenv("APP_NAME", "ecs-fargate-readiness-lab")
APP_ENV = os.getenv("APP_ENV", "local")
APP_VERSION = os.getenv("APP_VERSION", "0.1.0")
BUILD_ID = os.getenv("BUILD_ID", "dev")
BUILD_DATE = os.getenv("BUILD_DATE", "unknown")


app = FastAPI(title=APP_NAME)


@app.get("/")
def read_root() -> dict[str, str]:
    return {
        "service": APP_NAME,
        "environment": APP_ENV,
        "version": APP_VERSION,
        "build_id": BUILD_ID,
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/health")
def healthcheck() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/version")
def version() -> dict[str, str]:
    return {
        "service": APP_NAME,
        "version": APP_VERSION,
        "build_id": BUILD_ID,
        "build_date": BUILD_DATE,
    }
