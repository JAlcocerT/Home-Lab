# Forgejo

Self-hosted Git service — a fork of Gitea. Compatible with the Gitea API.

## Setup

Copy the sample env file and fill in your credentials:

```bash
cp .env.sample .env
```

| Variable | Description |
|---|---|
| `GITHUB_USER` | Your GitHub username |
| `GITHUB_TOKEN` | GitHub PAT with `repo` scope |
| `FORGEJO_URL` | URL of your Forgejo instance |
| `FORGEJO_TOKEN` | Forgejo API token (UI → Settings → Applications) |
| `REPO_OWNER` | Owner for single-repo targets |
| `REPO_NAME` | Repo name for single-repo targets |

## Running

```bash
make up      # start stack
make down    # stop stack
make logs    # follow logs
make status  # show container state
```

Or directly with Docker:

```bash
docker compose up -d
```

- **Web UI**: http://localhost:3034
- **SSH**: port `2235`

Data is persisted at `/srv/confs/forgejo` and `/srv/databases/forgejo/mysql`.

---

## Migrating private GitHub repositories

### Single repo (via UI)

1. Go to `http://localhost:3034` and log in
2. Click **"+" → "Migrate Repository"**
3. Choose **GitHub** as the source
4. Fill in:
   - **Clone URL**: `https://github.com/your-org/your-repo`
   - **Token**: a GitHub PAT with `repo` scope
   - **Mirror**: enable to keep it in sync with GitHub automatically

### Getting the tokens

#### 1. GitHub PAT (`GITHUB_TOKEN`)

This is a single **account-level** token — one token covers all your repos (public and private). You do not need one per repo.

**Option A — Classic PAT (simpler)**

1. Go to **GitHub → Settings** (top-right avatar menu)
2. Scroll down to **Developer settings** (bottom of the left sidebar)
3. **Personal access tokens → Tokens (classic)**
4. Click **Generate new token (classic)**
5. Give it a name (e.g. `forgejo-mirror`) and set an expiry
6. Under **Select scopes**, tick **`repo`** (required to read private repos)
7. Click **Generate token** and copy it — you won't see it again

**Option B — Fine-grained PAT (recommended, read-only)**

1. **Developer settings → Personal access tokens → Fine-grained tokens**
2. Click **Generate new token**
3. Set **Resource owner** to your account - `https://github.com/settings/tokens`
4. Under **Repository access** → select **All repositories** (or pick specific ones) 
5. Under **Permissions → Repository permissions** → set **Contents** to `Read-only`
6. Generate and copy the token

> Fine-grained tokens are safer for mirroring — they cannot push, delete, or modify anything.

Paste it as `GITHUB_TOKEN` in your `.env`.

#### 2. Forgejo API token (`FORGEJO_TOKEN`)

1. Log in to your Forgejo instance at `http://localhost:3034`
   - First time: click **Register** to create your admin account
2. Go to **Settings** (top-right avatar menu) → **Applications** - `http://localhost:3034/user/settings/applications`
3. Under **Manage Access Tokens**, enter a token name (e.g. `cli`) and click **Generate Token**
4. Copy the token — it is only shown once

Paste it as `FORGEJO_TOKEN` in your `.env`.

### Full profile — all repos via Makefile

With `.env` populated, run:

```bash
make migrate-all   # migrate every repo in your GitHub profile
make sync-all      # trigger mirror sync on all mirrored repos
```

### Single repo via Makefile

```bash
make migrate-repo REPO_OWNER=your-user REPO_NAME=my-repo
make sync-repo    REPO_OWNER=your-user REPO_NAME=my-repo
```

Or set `REPO_OWNER` / `REPO_NAME` in `.env` and just run `make migrate-repo`.

### Available Makefile targets

```
make help
```

| Target | Description |
|---|---|
| `up` | Start Forgejo + DB |
| `down` | Stop and remove containers |
| `logs` | Follow container logs |
| `status` | Show running containers |
| `list-github-repos` | List repos visible to `GITHUB_TOKEN` |
| `list-repos` | List all repos on Forgejo |
| `migrate-repo` | Migrate one GitHub repo |
| `migrate-all` | Migrate all repos for `GITHUB_USER` |
| `sync-repo` | Trigger mirror sync for one repo |
| `sync-all` | Trigger mirror sync for every mirror |
| `list-users` | List all users on Forgejo |
| `create-user` | Create a non-admin user |
| `add-collaborator` | Add a user as write collaborator on a repo |

> If you have more than 100 repos on GitHub, paginate by running `migrate-all` with `&page=2` — or extend the script in the Makefile.

---

## User management

### Create a user

Users are created as non-admin with `must_change_password: true` — they set their own password on first login.

```bash
make create-user \
  NEW_USER=alice \
  NEW_USER_EMAIL=alice@example.com \
  NEW_USER_PASSWORD=changeme123
```

Or set `NEW_USER`, `NEW_USER_EMAIL`, `NEW_USER_PASSWORD` in `.env` and run `make create-user`.

### Grant repo access

```bash
# Give write access to a specific repo
make add-collaborator NEW_USER=alice REPO_OWNER=JAlcocerT REPO_NAME=my-repo

# List all users
make list-users
```

### Permission levels

| Level | Push | Delete repo | Change settings |
|---|---|---|---|
| `read` | no | no | no |
| `write` | yes | no | no |
| `admin` | yes | yes | yes |

`write` is the recommended level for collaborators — full read/write on code, issues and PRs, but no destructive or admin actions. `add-collaborator` always assigns `write`.

---

## Forgejo API

Interactive docs (Swagger UI): `http://localhost:3034/-/api/swagger`

### Authentication

```bash
# Token (recommended)
-H "Authorization: token YOUR_TOKEN"

# Basic auth
-H "Authorization: Basic $(echo -n user:pass | base64)"
```

### Key endpoints

| Area | Path |
|---|---|
| Repos (CRUD, migrate, topics) | `GET/POST /api/v1/repos/` |
| User & org management | `/api/v1/user`, `/api/v1/orgs/` |
| Issues & PRs | `/api/v1/repos/{owner}/{repo}/issues` |
| Releases & tags | `/api/v1/repos/{owner}/{repo}/releases` |
| Webhooks | `/api/v1/repos/{owner}/{repo}/hooks` |
| Admin (users, orgs, cron) | `/api/v1/admin/` |
| Notifications | `/api/v1/notifications` |

### Useful one-liners

```bash
# List all your repos on Forgejo
curl -s http://localhost:3034/api/v1/user/repos \
  -H "Authorization: token $FORGEJO_TOKEN" | jq '.[].name'

# Check mirror sync status
curl -s http://localhost:3034/api/v1/repos/{owner}/{repo} \
  -H "Authorization: token $FORGEJO_TOKEN" | jq '.mirror_updated'

# Trigger a mirror sync manually
curl -X POST http://localhost:3034/api/v1/repos/{owner}/{repo}/mirror-sync \
  -H "Authorization: token $FORGEJO_TOKEN"
```
