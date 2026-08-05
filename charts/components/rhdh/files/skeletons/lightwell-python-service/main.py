"""Minimal FastAPI PoC for Lightwell TSSC workshop Modules 7–9 (RHDH scaffold)."""

from __future__ import annotations

import os

import httpx
from fastapi import FastAPI, Query

app = FastAPI(
    title="${{ values.name }}",
    description="${{ values.description }}",
    version="0.1.0",
)

LIGHTWELL_STREAM = os.getenv("LIGHTWELL_STREAM", "validated")


@app.get("/api/greeting")
def greeting(name: str = Query(default="Lightwell", min_length=1)) -> dict[str, str]:
    """Return a greeting; demonstrates httpx (LWN Validated demo dependency)."""
    safe_name = name.strip() or "Lightwell"
    # Touch httpx so the Validated pin is a real runtime import (not unused).
    _ = httpx.__version__
    return {
        "message": f"Hello, {safe_name}!",
        "lightwellStream": LIGHTWELL_STREAM,
        "service": "${{ values.name }}",
        "httpxVersion": httpx.__version__,
    }


@app.get("/api/healthz")
def healthz() -> dict[str, str]:
    """Liveness-style health probe."""
    return {"status": "ok"}
