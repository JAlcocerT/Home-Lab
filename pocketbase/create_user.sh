#!/usr/bin/env bash
set -euo pipefail

# --- Config loading ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
ENV_SAMPLE_FILE="${SCRIPT_DIR}/.env.sample"

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
elif [[ -f "${ENV_SAMPLE_FILE}" ]]; then
  echo "WARN: .env not found. Falling back to .env.sample"
  # shellcheck disable=SC1090
  source "${ENV_SAMPLE_FILE}"
else
  echo "ERROR: Neither .env nor .env.sample found in ${SCRIPT_DIR}" >&2
  exit 1
fi

: "${POCKETBASE_URL:?POCKETBASE_URL is required in .env}"
: "${ADMIN_EMAIL:?ADMIN_EMAIL is required in .env}"
: "${ADMIN_PASSWORD:?ADMIN_PASSWORD is required in .env}"
: "${NEW_USER_EMAIL:?NEW_USER_EMAIL is required in .env}"
: "${NEW_USER_PASSWORD:?NEW_USER_PASSWORD is required in .env}"

TOKEN_FILE="${SCRIPT_DIR}/.user_token"

# --- Dependencies check ---
if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required." >&2
  exit 1
fi

# --- Helpers ---
log() { echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"; }
fail() { echo "ERROR: $*" >&2; exit 1; }

# --- Wait for PocketBase health ---
log "Waiting for PocketBase at ${POCKETBASE_URL} ..."
for i in {1..30}; do
  if curl -fsS "${POCKETBASE_URL}/api/health" >/dev/null 2>&1; then
    log "PocketBase is healthy."
    break
  fi
  sleep 1
  if [[ $i -eq 30 ]]; then
    fail "PocketBase did not become healthy in time."
  fi
done

# --- Admin auth ---
log "Authenticating as admin..."
ADMIN_AUTH_RESP="$(curl -fsS -X POST "${POCKETBASE_URL}/api/admins/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "$(jq -nc --arg identity "$ADMIN_EMAIL" --arg password "$ADMIN_PASSWORD" '{identity:$identity, password:$password}')" \
)"
ADMIN_TOKEN="$(echo "${ADMIN_AUTH_RESP}" | jq -r '.token // empty')"
if [[ -z "${ADMIN_TOKEN}" || "${ADMIN_TOKEN}" == "null" ]]; then
  echo "${ADMIN_AUTH_RESP}" | jq '.' || true
  fail "Failed to authenticate admin."
fi
log "Admin authenticated."

AUTHZ_HEADER="Authorization: Bearer ${ADMIN_TOKEN}"

# --- Check if user exists ---
FILTER=$(python3 - <<'PY' 2>/dev/null || true
import json, sys, urllib.parse, os
email = os.environ.get("NEW_USER_EMAIL","")
flt = f'email="{email}"'
print(urllib.parse.urlencode({"filter": flt}))
PY
)
if [[ -z "${FILTER}" ]]; then
  # Fallback without python
  RAW_FILTER="email=\"${NEW_USER_EMAIL}\""
  FILTER="filter=$(printf '%s' "${RAW_FILTER}" | sed -e 's/"/%22/g' -e 's/ /%20/g' -e 's/=/%3D/g')"
fi

log "Checking if user ${NEW_USER_EMAIL} exists..."
LIST_URL="${POCKETBASE_URL}/api/collections/users/records?${FILTER}&perPage=1"
USER_LIST="$(curl -fsS -H "${AUTHZ_HEADER}" "${LIST_URL}")"
TOTAL="$(echo "${USER_LIST}" | jq -r '.total // 0')"

if [[ "${TOTAL}" -ge 1 ]]; then
  USER_ID="$(echo "${USER_LIST}" | jq -r '.items[0].id')"
  log "User exists with id=${USER_ID}"
else
  # --- Create user ---
  log "User not found. Creating user ${NEW_USER_EMAIL} ..."
  CREATE_PAYLOAD="$(jq -nc \
    --arg email "$NEW_USER_EMAIL" \
    --arg password "$NEW_USER_PASSWORD" \
    '{email:$email, password:$password, passwordConfirm:$password, emailVisibility:true}'
  )"
  CREATE_RESP="$(curl -fsS -X POST "${POCKETBASE_URL}/api/collections/users/records" \
    -H "Content-Type: application/json" \
    -H "${AUTHZ_HEADER}" \
    -d "${CREATE_PAYLOAD}" \
  )" || {
    echo "${CREATE_RESP:-}" >&2
    fail "Failed to create user."
  }
  USER_ID="$(echo "${CREATE_RESP}" | jq -r '.id // empty')"
  if [[ -z "${USER_ID}" || "${USER_ID}" == "null" ]]; then
    echo "${CREATE_RESP}" | jq '.' || true
    fail "User creation did not return an id."
  fi
  log "User created with id=${USER_ID}"
fi

# --- User auth to get bearer token ---
log "Authenticating user to obtain bearer token..."
USER_AUTH_RESP="$(curl -fsS -X POST "${POCKETBASE_URL}/api/collections/users/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "$(jq -nc --arg identity "$NEW_USER_EMAIL" --arg password "$NEW_USER_PASSWORD" '{identity:$identity, password:$password}')" \
)"
USER_TOKEN="$(echo "${USER_AUTH_RESP}" | jq -r '.token // empty')"
if [[ -z "${USER_TOKEN}" || "${USER_TOKEN}" == "null" ]]; then
  echo "${USER_AUTH_RESP}" | jq '.' || true
  fail "Failed to authenticate user."
fi

printf '%s\n' "${USER_TOKEN}" > "${TOKEN_FILE}"
log "User bearer token saved to ${TOKEN_FILE}"
echo "${USER_TOKEN}"