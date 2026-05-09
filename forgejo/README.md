# Forgejo

Self-hosted Git service — a fork of Gitea. Compatible with the Gitea API.

## Running

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

### GitHub PAT

Generate at: GitHub → Settings → Developer settings → Personal access tokens → Generate new token (classic)

Required scope: `repo` (full access to private repos)

### Full profile — all repos via API

Requires `jq`. Generate a Forgejo API token first: Forgejo UI → Settings → Applications → Generate Token.

```bash
GITHUB_USER="your-github-username"
GITHUB_TOKEN="ghp_yourGitHubPAT"
FORGEJO_URL="http://localhost:3034"
FORGEJO_TOKEN="your-forgejo-token"

repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/user/repos?per_page=100&type=all" \
  | jq -r '.[].clone_url')

for repo in $repos; do
  repo_name=$(basename "$repo" .git)
  echo "Migrating $repo_name..."
  curl -s -X POST "$FORGEJO_URL/api/v1/repos/migrate" \
    -H "Authorization: token $FORGEJO_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"clone_addr\": \"$repo\",
      \"auth_token\": \"$GITHUB_TOKEN\",
      \"repo_name\": \"$repo_name\",
      \"private\": true,
      \"mirror\": true,
      \"wiki\": true,
      \"issues\": true,
      \"pull_requests\": true,
      \"releases\": true,
      \"labels\": true,
      \"milestones\": true
    }"
done
```

> If you have more than 100 repos, paginate with `&page=2`, `&page=3`, etc.

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
