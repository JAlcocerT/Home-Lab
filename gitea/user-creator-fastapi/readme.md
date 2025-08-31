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

Make a fork from an admin own repo for that new user:

```sh
curl -sS -X POST \
  -H "Authorization: token $GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}' \
  "$GITEA_BASE/repos/reisikei/sample-repo/forks?sudo=yosua" | jq '.full_name,.fork'
```