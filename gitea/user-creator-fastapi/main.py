import os
from typing import Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel, EmailStr, Field
import httpx
from dotenv import load_dotenv

app = FastAPI(title="Gitea User Creator")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Resolve static directory next to this file
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Load .env from project root (same directory as this file) BEFORE reading envs
load_dotenv(os.path.join(BASE_DIR, ".env"))

# Read env after loading .env
GITEA_BASE = os.getenv("GITEA_BASE", "http://localhost:3000").rstrip("/")
GITEA_TOKEN = os.getenv("GITEA_TOKEN", "")
STATIC_DIR = os.path.join(BASE_DIR, "static")

# Serve static UI at /static and index at /
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

@app.get("/")
async def index():
    return FileResponse(os.path.join(STATIC_DIR, "index.html"))


class CreateUserIn(BaseModel):
    username: str = Field(min_length=1)
    email: EmailStr
    password: str = Field(min_length=6)
    full_name: Optional[str] = None
    must_change_password: bool = False
    send_notify: bool = False


class CreateUserOut(BaseModel):
    id: int
    username: str
    email: EmailStr
    full_name: Optional[str] = None


@app.get("/health")
async def health():
    return {"ok": True}


@app.post("/api/create_user", response_model=CreateUserOut)
async def create_user(payload: CreateUserIn):
    if not GITEA_TOKEN:
        raise HTTPException(status_code=500, detail="GITEA_TOKEN is not configured on the server")

    url = f"{GITEA_BASE}/api/v1/admin/users"
    headers = {"Authorization": f"token {GITEA_TOKEN}", "Content-Type": "application/json"}

    data = {
        "username": payload.username,
        "email": str(payload.email),
        "password": payload.password,
        "full_name": payload.full_name or "",
        "must_change_password": payload.must_change_password,
        "send_notify": payload.send_notify,
    }

    async with httpx.AsyncClient(timeout=15) as client:
        try:
            resp = await client.post(url, headers=headers, json=data)
        except httpx.RequestError as e:
            raise HTTPException(status_code=502, detail=f"Failed to reach Gitea: {e}")

    if resp.status_code >= 400:
        try:
            detail = resp.json()
        except Exception:
            detail = {"message": resp.text}
        raise HTTPException(status_code=resp.status_code, detail=detail)

    j = resp.json()
    return CreateUserOut(
        id=j.get("id"),
        username=j.get("login") or j.get("username"),
        email=j.get("email"),
        full_name=j.get("full_name"),
    )
