import os
from typing import Optional

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel, EmailStr, Field
import httpx
from dotenv import load_dotenv
import hmac
import hashlib
import json
import asyncio
import subprocess
import logging

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
WEBHOOK_SECRET = os.getenv("WEBHOOK_SECRET", "")
BUILD_ROOT = os.getenv("BUILD_ROOT", "/srv/builds")
REPO_MAP = {}
try:
    REPO_MAP = json.loads(os.getenv("REPO_MAP", "{}"))
except Exception:
    REPO_MAP = {}
STATIC_DIR = os.path.join(BASE_DIR, "static")

# Basic logging setup
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

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


class LoginIn(BaseModel):
    username: str
    password: str


class Repo(BaseModel):
    name: str
    full_name: Optional[str] = None
    private: Optional[bool] = None
    html_url: Optional[str] = None


class ReposOut(BaseModel):
    username: str
    repos: list[Repo]


class ImportRepoIn(BaseModel):
    username: str = Field(min_length=1, description="Target Gitea username (owner)")
    repo_name: str = Field(min_length=1, description="New repo name in Gitea")
    clone_url: str = Field(min_length=1, description="Public Git URL to import (e.g., https://github.com/org/repo.git)")
    private: bool = False
    description: Optional[str] = None


class ImportRepoOut(BaseModel):
    full_name: str
    html_url: Optional[str] = None
    private: Optional[bool] = None


@app.post("/api/login_and_repos", response_model=ReposOut)
async def login_and_repos(payload: LoginIn):
    # Use Basic Auth with the user's credentials to fetch their owned repos
    auth = (payload.username, payload.password)
    url = f"{GITEA_BASE}/api/v1/user/repos"
    params = {"limit": 100, "page": 1, "type": "owner", "sort": "updated", "direction": "desc"}

    async with httpx.AsyncClient(timeout=15, auth=auth) as client:
        try:
            resp = await client.get(url, params=params)
        except httpx.RequestError as e:
            raise HTTPException(status_code=502, detail=f"Failed to reach Gitea: {e}")

    if resp.status_code == 401:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    if resp.status_code >= 400:
        try:
            detail = resp.json()
        except Exception:
            detail = {"message": resp.text}
        raise HTTPException(status_code=resp.status_code, detail=detail)

    items = resp.json() or []
    repos = [
        Repo(
            name=i.get("name"),
            full_name=i.get("full_name"),
            private=i.get("private"),
            html_url=i.get("html_url"),
        )
        for i in items
    ]
    return ReposOut(username=payload.username, repos=repos)


@app.post("/api/create_user_and_repos")
async def create_user_and_repos(payload: CreateUserIn):
    # Create user using admin token, then list repos using their credentials
    created = await create_user(payload)
    repos = await login_and_repos(LoginIn(username=created.username, password=payload.password))
    return {"created": created, "repos": repos}


@app.post("/api/import_public_repo", response_model=ImportRepoOut)
async def import_public_repo(payload: ImportRepoIn):
    """
    Import (migrate) a public Git repository (e.g., from GitHub) into a user's
    Gitea account by calling Gitea's migrate API with admin token + sudo.
    """
    if not GITEA_TOKEN:
        raise HTTPException(status_code=500, detail="GITEA_TOKEN is not configured on the server")

    url = f"{GITEA_BASE}/api/v1/repos/migrate?sudo={payload.username}"
    headers = {"Authorization": f"token {GITEA_TOKEN}", "Content-Type": "application/json"}

    data = {
        "clone_addr": payload.clone_url,
        "repo_name": payload.repo_name,
        "repo_owner": payload.username,
        "description": payload.description or "",
        "private": payload.private,
        # common migrate toggles (safe defaults)
        "mirror": False,
        "wiki": True,
        "issues": True,
        "labels": True,
        "pull_requests": True,
        "releases": True,
    }

    async with httpx.AsyncClient(timeout=30) as client:
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

    j = resp.json() or {}
    return ImportRepoOut(
        full_name=j.get("full_name") or f"{payload.username}/{payload.repo_name}",
        html_url=j.get("html_url"),
        private=j.get("private"),
    )


def verify_signature(sig_header: str, body: bytes) -> bool:
    if not WEBHOOK_SECRET:
        # If no secret configured, accept nothing (safer). You can relax if needed.
        return False
    if not sig_header:
        return False
    expected = hmac.new(WEBHOOK_SECRET.encode("utf-8"), body, hashlib.sha256).hexdigest()
    try:
        return hmac.compare_digest(expected, sig_header)
    except Exception:
        return False


def _run_cmd(cmd: list[str], cwd: Optional[str] = None) -> int:
    """Run a command, log stdout/stderr, and return exit code."""
    try:
        logger.info("Running: %s (cwd=%s)", " ".join(cmd), cwd or "")
        res = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
        if res.stdout:
            logger.info("stdout:\n%s", res.stdout.strip()[:4000])
        if res.stderr:
            logger.info("stderr:\n%s", res.stderr.strip()[:4000])
        logger.info("exit code: %s", res.returncode)
        return res.returncode
    except Exception as e:
        logger.exception("Command failed to start: %s", e)
        return 1


async def run_build(repo_full_name: str, branch: str):
    # Determine working directory
    workdir = REPO_MAP.get(repo_full_name)
    if not workdir:
        # default to BUILD_ROOT/owner/repo
        workdir = os.path.join(BUILD_ROOT, *repo_full_name.split("/"))
    os.makedirs(workdir, exist_ok=True)

    # If directory doesn't contain a .git, try to clone
    if not os.path.isdir(os.path.join(workdir, ".git")):
        clone_url = f"{GITEA_BASE.replace('/api/v1','')}/{repo_full_name}.git"
        logger.info("Cloning repo %s into %s (branch=%s)", clone_url, workdir, branch)
        _run_cmd(["git", "clone", "--branch", branch, clone_url, workdir])

    # Fetch latest and checkout branch
    logger.info("Updating and building %s at %s (branch=%s)", repo_full_name, workdir, branch)
    steps = [
        ["git", "-C", workdir, "fetch", "--all", "--prune"],
        ["git", "-C", workdir, "checkout", branch],
        ["git", "-C", workdir, "pull", "--ff-only"],
        ["bash", "-lc", "npm ci"],
        ["bash", "-lc", "npm run build"],
    ]
    for step in steps:
        code = _run_cmd(step, cwd=workdir)
        if code != 0:
            logger.warning("Step failed (exit=%s), continuing: %s", code, " ".join(step))


@app.post("/webhook")
async def webhook(request: Request):
    sig = request.headers.get("X-Gitea-Signature")
    event = request.headers.get("X-Gitea-Event")
    body = await request.body()

    if not verify_signature(sig, body):
        raise HTTPException(status_code=401, detail="invalid signature")

    try:
        payload = json.loads(body.decode("utf-8"))
    except Exception:
        raise HTTPException(status_code=400, detail="invalid json payload")

    if event != "push":
        logger.info("Webhook received non-push event: %s", event)
        return {"ok": True, "ignored": event}

    repo = (payload.get("repository") or {}).get("full_name")
    ref = payload.get("ref", "")  # e.g., refs/heads/main
    branch = ref.split("/")[-1] if ref else "main"

    if not repo:
        logger.info("Webhook push missing repo info; ignoring")
        return {"ok": True, "ignored": "no repo"}

    # Kick off build in background; return quickly
    logger.info("Webhook push queued: repo=%s branch=%s", repo, branch)
    asyncio.create_task(run_build(repo, branch))
    return {"ok": True, "repo": repo, "branch": branch, "queued": True}
