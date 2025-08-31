Run the service

```sh
#uv pip compile pyproject.toml -o requirements.txt
uv sync
uv lock
```

```sh
uv run uvicorn main:app --host 0.0.0.0 --port 8055
```

See that the user is created in Gitea

```sh
curl -s -H "Authorization: token $GITEA_TOKEN" \
  "$GITEA_BASE/admin/users?limit=50&page=1" | jq '.[].login'
```

Make a fork from an admin own repo (from inside gitea)for that new user:

```sh
curl -sS -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}' \
  "$GITEA_BASE/repos/reisikei/sample-repo/forks?sudo=yosua" | jq '.full_name,.fork'
```

- List repos under a given user: Public repos (no sudo; works for any visible user):

```bash
USER="yosua"
curl -s -H "Authorization: token $GITEA_TOKEN" \
  "$GITEA_BASE/users/$USER/repos?limit=50&page=1" | jq '.[].full_name'
```

Or fork for that user a public repo from outside gitea (Github): Import a public GitHub repo into the new user's namespace (admin-initiated)

- Variant A: use `sudo=yosua` to act as the user. Post to the migrate endpoint with the GitHub clone URL.

```sh
curl -sS -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clone_addr": "https://github.com/ctrimm/astro-payroll-solution-theme.git",
    "repo_name": "astro-payroll-solution-theme",
    "mirror": false,
    "private": false,
    "description": "Imported from GitHub"
  }' \
  "$GITEA_BASE/repos/migrate?sudo=yosua" | jq '.full_name,.private,.mirror'
```

**Notes:**

- Ensure `$GITEA_TOKEN` belongs to an admin.
- `$GITEA_BASE` should point to your Gitea API base (e.g., http://host:port/api/v1). If your `$GITEA_BASE` does not include `/api/v1`, append it in the URL paths above.

Yes. As a Gitea admin you can create repo webhooks on behalf of a user using the sudo query param.

# How to create a webhook as admin (impersonating user)

- Define an API base variable that works with your setup:
  - If your GITEA_BASE does NOT include /api/v1: API="$GITEA_BASE/api/v1"
  - If it already includes /api/v1: API="$GITEA_BASE"

- Create a webhook on the user’s repository:

```bash
USER="yosua"
OWNER="yosua"                   # repo owner (for personal repo this equals the username)
REPO="astro-payroll-solution-theme"
WEBHOOK_URL="http://192.168.1.11:8055/webhook"
WEBHOOK_SECRET="change_me"

API="${GITEA_BASE%/}/api/v1"   # adjust if your GITEA_BASE already has /api/v1

curl -sS -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"type\": \"gitea\",
    \"config\": {
      \"url\": \"${WEBHOOK_URL}\",
      \"content_type\": \"json\",
      \"secret\": \"${WEBHOOK_SECRET}\"
    },
    \"events\": [\"push\"],
    \"active\": true
  }" \
  "$API/repos/$OWNER/$REPO/hooks?sudo=$USER" | jq '{id,active,config:{url: .config.url}}'
```

# Useful follow-ups

- List hooks:

```bash
curl -s "$API/repos/$OWNER/$REPO/hooks?sudo=$USER" \
  -H "Authorization: token $GITEA_TOKEN" | jq '.[].id'
```

- Update a hook (e.g., add more events):
```bash
HOOK_ID=123
curl -sS -X PATCH \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"events":["push","pull_request"],"active":true}' \
  "$API/repos/$OWNER/$REPO/hooks/$HOOK_ID?sudo=$USER" | jq '{id,events}'
```

- Delete a hook:
```bash
HOOK_ID=123
curl -sS -X DELETE \
  -H "Authorization: token $GITEA_TOKEN" \
  "$API/repos/$OWNER/$REPO/hooks/$HOOK_ID?sudo=$USER" -w '%{http_code}\n'
```

# Notes
- Ensure the webhook secret matches `WEBHOOK_SECRET` in `gitea/user-creator-fastapi/.env`.
- For org repos, use `/orgs/{org}/hooks?sudo=$USER`. For user-level hooks (fire for all their repos), use `/users/{user}/hooks?sudo=$USER`.