# Gitea API 1.24 — Quick Start

Base URL for your instance:

- `http://192.168.1.11:3033/api/v1`

## Authentication

- Personal Access Token (recommended)
  1) In Gitea UI: Settings → Applications → Generate Token
  2) Use header: `Authorization: token YOUR_TOKEN`
- Alternatives: Basic auth (`-u user:pass`), OAuth2 (if configured)

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
