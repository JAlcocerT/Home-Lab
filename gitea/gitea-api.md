# Gitea API 1.24 — Quick Start

> Terminology: “API” is a general term. In this doc it means Gitea’s HTTP REST API (JSON over HTTP). Webhooks are outbound HTTP callbacks from Gitea to your service; they are not requests you send to the API.

Base URL for your instance:

- `http://192.168.1.11:3033/api/v1`

API vs Webhooks

 - API calls (your curls): you call Gitea’s REST endpoints to read data (GET) or change state (POST/PUT/PATCH/DELETE) using an auth token.
 - Webhooks: Gitea calls your HTTP endpoint when events occur (push, issues, PRs, releases). You typically verify the HMAC signature, then optionally call the API to act.
 - Together: Use the API to configure webhooks; on webhook receipt, use IDs from the payload to fetch more details or perform actions via the API.

## Authentication

Personal Access Token (PAT is the recommended way)

  1) In Gitea UI: Settings → Applications → Generate Token
  2) Use header: `Authorization: token YOUR_TOKEN`

> Alternatives: Basic auth (`-u user:pass`), OAuth2 (if configured)

Tip: export your token for reuse

```bash
#source .env
export GITEA_BASE="http://192.168.1.11:3033/api/v1"
export GITEA_TOKEN="<your_token_here>"
#echo $GITEA_TOKEN
```

## Common cURL examples

- Current user

```bash
curl -s -H "Authorization: token $GITEA_TOKEN" \
  "$GITEA_BASE/user" | jq
```

- List your repositories

```bash
curl -s -H "Authorization: token $GITEA_TOKEN" \
  "$GITEA_BASE/user/repos?limit=50&page=1" | jq '.[].full_name'
```

- Create a repository

```bash
curl -s -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"demo-repo2","private":true,"description":"Demo"}' \
  "$GITEA_BASE/user/repos" | jq '.full_name,.html_url'
```

- Create an issue

```bash
OWNER="<owner>"; REPO="<repo>"
curl -s -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test issue","body":"Created via API"}' \
  "$GITEA_BASE/repos/$OWNER/$REPO/issues" | jq '.number,.title'
```

- Add a webhook to a repo

```bash
OWNER="<owner>"; REPO="<repo>"
curl -s -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "gitea",
    "config": { "url": "http://your-listener/hook", "content_type": "json", "secret": "s3cr3t" },
    "events": ["push","pull_request"],
    "active": true
  }' \
  "$GITEA_BASE/repos/$OWNER/$REPO/hooks" | jq '.id,.config.url'
```

**Copying repos (fork vs mirror vs clone)**

- Fork (keeps fork relationship)
```bash
# Authenticate as the target user (use their token)
NEW_USER_TOKEN="$GITEA_TOKEN" # or another var holding the new user's token
curl -s -X POST \
  -H "Authorization: token $NEW_USER_TOKEN" \
  "$GITEA_BASE/repos/<other_owner>/<repo>/forks" | jq '.full_name,.fork'
```

- Mirror/import (no fork relationship; optional auto-sync)
```bash
# As admin: create a mirror owned by a user (uid from GET /users/{username})
ALICE_UID=$(curl -s "$GITEA_BASE/users/alice" | jq -r '.id')
curl -s -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clone_addr": "http://192.168.1.11:3033/<other_owner>/<repo>.git",
    "repo_name": "repo-mirror",
    "uid": '"$ALICE_UID"',
    "mirror": true,
    "private": false
  }' \
  "$GITEA_BASE/repos/migrate" | jq '.full_name,.mirror'
```

- Plain git clone (local working copy only)
```bash
git clone http://192.168.1.11:3033/<other_owner>/<repo>.git
```

### Admin impersonation (sudo) + migrate private repos

- **Impersonate a user** with `sudo=<username>` (admin token required)

```bash
# Fork an admin-owned repo into alice's namespace (keeps fork relationship)
curl -s -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  "$GITEA_BASE/repos/<admin_owner>/<repo>/forks?sudo=alice" | jq '.full_name,.fork'

# curl -s -X POST \
#   -H "Authorization: token $GITEA_TOKEN" \
#   "$GITEA_BASE/repos/reisikei/sample-repo/forks?sudo=alice" | jq '.full_name,.fork'

#example
curl -sS -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}' \
  "$GITEA_BASE/repos/reisikei/sample-repo/forks?sudo=alice" | jq '.full_name,.fork'
```

```sh
# Create a repo as alice (acts as that user)
curl -s -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"alice-repo"}' \
  "$GITEA_BASE/user/repos?sudo=alice" | jq '.full_name'
```

- Server-side migrate/copy a repo into a user (works for private sources with auth)
```bash
ALICE_UID=$(curl -s "$GITEA_BASE/users/alice" | jq -r '.id')
curl -s -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clone_addr": "http://192.168.1.11:3033/<admin_owner>/<repo>.git",
    "repo_name": "admin-repo-copy",
    "uid": '"$ALICE_UID"',
    "mirror": false,
    "private": true
  }' \
  "$GITEA_BASE/repos/migrate" | jq '.full_name'
```

## Useful endpoints (prefix `/api/v1`)

- Users: `/user`, `/users/{username}`
- Repos: `/user/repos`, `/orgs/{org}/repos`, `/repos/{owner}/{repo}`
- Issues: `/repos/{owner}/{repo}/issues`
- Pulls: `/repos/{owner}/{repo}/pulls`
- Orgs: `/user/orgs`, `/orgs/{org}`
- Admin (admin token): `/admin/users`, etc.

## Admin: user management

Requires an admin token (PAT generated by an admin account). 

> Non-admin tokens cannot create/list all users.

- Create a user

```bash
curl -s -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice",
    "email": "alice@example.com",
    "password": "StrongPass123!",
    "full_name": "Alice Example",
    "must_change_password": true,
    "send_notify": false
  }' \
  "$GITEA_BASE/admin/users" | jq
```

- List users (paginate)

```bash
curl -s -H "Authorization: token $GITEA_TOKEN" \
  "$GITEA_BASE/admin/users?limit=50&page=1" | jq '.[].login'
```

- **List repos under a given user**

Public repos (no sudo; works for any visible user):
```bash
USER="alice"
curl -s -H "Authorization: token $GITEA_TOKEN" \
  "$GITEA_BASE/users/$USER/repos?limit=50&page=1" | jq '.[].full_name'
```

Include private repos (admin token impersonates the user):
```bash
USER="alice"
curl -s -H "Authorization: token $GITEA_TOKEN" \
  "$GITEA_BASE/user/repos?limit=50&page=1&sudo=$USER" | jq '.[].full_name'
```

See when a repo was last modified
```sh
OWNER="alice"; REPO="sample-repo"
DEFAULT_BRANCH=$(curl -s -H "Authorization: token $GITEA_TOKEN" \
  "$GITEA_BASE/repos/$OWNER/$REPO" | jq -r '.default_branch')

curl -s -H "Authorization: token $GITEA_TOKEN" \
  "$GITEA_BASE/repos/$OWNER/$REPO/commits?sha=$DEFAULT_BRANCH&limit=1" \
  | jq '.[0] | {sha, author: .commit.author.name, committed: .commit.author.date}'
```

## Useful endpoints (prefix `/api/v1`)

- Users: `/user`, `/users/{username}`
- Repos: `/user/repos`, `/orgs/{org}/repos`, `/repos/{owner}/{repo}`
- Issues: `/repos/{owner}/{repo}/issues`
- Pulls: `/repos/{owner}/{repo}/pulls`
- Orgs: `/user/orgs`, `/orgs/{org}`
- Admin (admin token): `/admin/users`, etc.

## Pagination and query params

- Common: `page`, `limit`, plus resource-specific filters (`q`, `archived`, `private`, ...)
- Iterate `page` until response is empty if headers don’t include pagination.

## Troubleshooting

- 401/403: missing or insufficient token scope → regenerate token with the right permissions.
- 404: wrong `owner/repo` or no access with this token.
- 422: invalid JSON or required fields missing.
- From browser JS, CORS can block calls; server-side (curl/backend) avoids this.

## References

- Docs: https://docs.gitea.com/api/1.24/
- (Sometimes) Swagger UI: `http://192.168.1.11:3033/api/swagger` (may not be enabled on all setups)
