#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   GITEA_BASE=http://192.168.1.11:3033 \
#   GITEA_TOKEN=... \
#   USER=yosua OWNER=yosua REPO=astro-payroll-solution-theme \
#   bash scripts/gitea-verify-and-test.sh
#
# Optional:
#   HOOK_ID=1  # if omitted, the script will try to discover it
#   WEBHOOK_URL=http://192.168.1.11:8055/webhook  # used to help select the correct hook
#   SUDO_HEADER=true  # force using Sudo header (default true)

GITEA_BASE=${GITEA_BASE:-}
GITEA_TOKEN=${GITEA_TOKEN:-}
USER_NAME=${USER:-}
OWNER=${OWNER:-}
REPO=${REPO:-}
HOOK_ID=${HOOK_ID:-}
WEBHOOK_URL=${WEBHOOK_URL:-}
SUDO_HEADER=${SUDO_HEADER:-true}

if [[ -z "$GITEA_BASE" || -z "$GITEA_TOKEN" || -z "$OWNER" || -z "$REPO" ]]; then
  echo "Missing required env. Set GITEA_BASE, GITEA_TOKEN, OWNER, REPO (and USER if private)." >&2
  exit 2
fi

API="${GITEA_BASE%/}/api/v1"
AUTH=(-H "Authorization: token $GITEA_TOKEN")
SUDO_OPTS=()
if [[ -n "${USER_NAME}" && "${SUDO_HEADER}" == "true" ]]; then
  SUDO_OPTS=(-H "Sudo: ${USER_NAME}")
fi

jq_present() { command -v jq >/dev/null 2>&1; }
color() { printf "\033[%sm%s\033[0m\n" "$1" "$2"; }
ok() { color 32 "✔ $1"; }
warn() { color 33 "! $1"; }
err() { color 31 "✘ $1"; }

step() { echo; color 36 "==> $1"; }

step "Check API base"
code=$(curl -sS -o /dev/null -w '%{http_code}' "$API/version") || true
if [[ "$code" != "200" ]]; then
  err "API/version not reachable at $API (code=$code)"; exit 1
fi
ok "Gitea API reachable ($API)"

step "Identify token user"
me=$(curl -sS "${AUTH[@]}" "$API/user") || true
if jq_present; then echo "$me" | jq '{login,is_admin}'; else echo "$me"; fi
ok "Token is valid"

step "Verify owner/user existence"
code=$(curl -sS -o /dev/null -w '%{http_code}' "${AUTH[@]}" "$API/users/$OWNER") || true
if [[ "$code" != "200" ]]; then err "Owner $OWNER not found (code=$code)"; exit 1; fi
ok "Owner $OWNER exists"

step "Verify repo"
repo_json=$(curl -sS "${AUTH[@]}" "${SUDO_OPTS[@]}" "$API/repos/$OWNER/$REPO" -w '\n%{http_code}\n')
repo_code=$(echo "$repo_json" | tail -n1)
repo_body=$(echo "$repo_json" | head -n -1)
if [[ "$repo_code" != "200" ]]; then
  err "Repo $OWNER/$REPO not accessible (code=$repo_code)"; echo "$repo_body"; exit 1
fi
ok "Repo $OWNER/$REPO accessible"

step "List webhooks"
hooks=$(curl -sS "${AUTH[@]}" "${SUDO_OPTS[@]}" "$API/repos/$OWNER/$REPO/hooks" -w '\n%{http_code}\n')
hooks_code=$(echo "$hooks" | tail -n1)
hooks_body=$(echo "$hooks" | head -n -1)
if [[ "$hooks_code" != "200" ]]; then
  err "Failed to list hooks (code=$hooks_code)"; echo "$hooks_body"; exit 1
fi
if jq_present; then echo "$hooks_body" | jq .; else echo "$hooks_body"; fi

if [[ -z "$HOOK_ID" ]]; then
  if jq_present; then
    if [[ -n "$WEBHOOK_URL" ]]; then
      HOOK_ID=$(echo "$hooks_body" | jq -r ".[] | select(.config.url == \"$WEBHOOK_URL\") | .id" | head -n1)
    fi
    if [[ -z "${HOOK_ID}" || "${HOOK_ID}" == "null" ]]; then
      HOOK_ID=$(echo "$hooks_body" | jq -r '.[0].id')
    fi
  else
    warn "jq not installed; cannot auto-select HOOK_ID. Set HOOK_ID manually."
  fi
fi
if [[ -z "$HOOK_ID" || "$HOOK_ID" == "null" ]]; then
  err "No webhook found. Create one in the repo settings (URL should point to your FastAPI /webhook)."
  exit 1
fi
ok "Using HOOK_ID=$HOOK_ID"

step "Trigger webhook test"
code=$(curl -sS -L -X POST "${AUTH[@]}" "${SUDO_OPTS[@]}" \
  "$API/repos/$OWNER/$REPO/hooks/$HOOK_ID/tests" \
  -o /dev/null -w '%{http_code}') || true
if [[ "$code" != "204" ]]; then err "Test trigger failed (code=$code)"; exit 1; fi
ok "Webhook test triggered (204). Check FastAPI logs and Gitea deliveries."

exit 0
