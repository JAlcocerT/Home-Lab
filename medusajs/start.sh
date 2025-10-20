#!/usr/bin/env bash
set -euo pipefail

# Expect app code to be mounted at /server (binds from ./app)
if [ ! -f /server/package.json ]; then
  echo "[medusa] No project found in /server.\n"
  echo "Mount your Medusa app at ./medusajs/app (host) so it appears in /server (container)."
  echo "You can scaffold one with: npx create-medusa-app@latest"
  sleep 2
  exit 1
fi

# Ensure node modules
if [ ! -d /server/node_modules ]; then
  echo "[medusa] Installing dependencies..."
  cd /server
  if [ -f yarn.lock ]; then
    corepack enable || true
    yarn install --frozen-lockfile || yarn install
  else
    npm ci || npm install
  fi
fi

# Export DB/Redis envs for app
export DATABASE_URL=${DATABASE_URL:-postgres://medusa:medusa@postgres:5432/medusa}
export REDIS_URL=${REDIS_URL:-redis://redis:6379}
export NODE_ENV=${NODE_ENV:-development}

cd /server

# Try common scripts: start:dev -> dev -> start
if npm run | grep -q "start:dev"; then
  echo "[medusa] Starting with npm run start:dev on 0.0.0.0:9000"
  HOST=0.0.0.0 npm run start:dev
elif npm run | grep -q "dev"; then
  echo "[medusa] Starting with npm run dev on 0.0.0.0:9000"
  HOST=0.0.0.0 npm run dev
else
  echo "[medusa] Starting with npm start on 0.0.0.0:9000"
  HOST=0.0.0.0 npm start
fi
