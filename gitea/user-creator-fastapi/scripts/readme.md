# Helper scripts

These scripts live in `gitea/user-creator-fastapi/scripts/` and are meant to simplify common tasks.

## gitea-verify-and-test.sh
Purpose: Verify Gitea connectivity and trigger a webhook test delivery.

It checks:
- API base/version, token identity (and admin if using sudo)
- Owner exists, repo is accessible
- Lists webhooks and auto-selects `HOOK_ID` (optionally matching `WEBHOOK_URL`)
- Triggers the Gitea webhook "test delivery" (HTTP 204 from the API means scheduled)

Usage:
```sh
chmod +x gitea-verify-and-test.sh build-and-dev.sh
# or, from the project root:
# chmod +x scripts/gitea-verify-and-test.sh scripts/build-and-dev.sh
```

```sh
cd /home/jalcocert/Home-Lab/gitea/user-creator-fastapi
source .env
#export GITEA_BASE="http://192.168.1.11:3033"
#export GITEA_TOKEN="...admin token..."
export USER="yosua"
export OWNER="yosua"
export REPO="astro-payroll-solution-theme"
scripts/gitea-verify-and-test.sh
```

Optional envs: `HOOK_ID=...`, `WEBHOOK_URL=http://user-creator-fastapi:8055/webhook`.

## build-and-dev.sh
Purpose: Run a one-off Node build in a given project directory, and optionally start its dev server.

Behavior:
- cd into the given path
- run `npm ci` (unless `--skip-ci`)
- run `npm run build`
- if `--dev` is provided, run `npm run dev` in the foreground

Usage:
```sh
BUILD_ROOT=/home/jalcocert
PROJECT="$BUILD_ROOT/BeyondAJourney/astro-news"
./build-and-dev.sh "$PROJECT"
# ./build-and-dev.sh "$PROJECT" --skip-ci
# ./build-and-dev.sh "$PROJECT" --dev
```

Notes:
- This script is on-demand; it does not "listen". Listening for pushes is handled by FastAPI `/webhook`.
- Ensure `node` and `npm` are installed and on PATH, or set `NODE_BIN` to include them.