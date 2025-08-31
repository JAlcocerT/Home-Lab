#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash scripts/build-and-dev.sh /path/to/project [--skip-ci] [--dev]
#
# Behavior:
#   - cd into the given path
#   - run `npm ci` (unless --skip-ci)
#   - run `npm run build`
#   - if --dev is provided, then run `npm run dev` (foreground)
#
# Env overrides:
#   NODE_BIN: path to node/npm directory to prepend to PATH

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /abs/path [--skip-ci] [--dev]" >&2
  exit 2
fi

PROJECT_PATH=$1; shift || true
SKIP_CI=false
RUN_DEV=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-ci) SKIP_CI=true; shift ;;
    --dev) RUN_DEV=true; shift ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "Path not found: $PROJECT_PATH" >&2
  exit 1
fi

if [[ -n "${NODE_BIN:-}" ]]; then
  export PATH="$NODE_BIN:$PATH"
fi

if ! command -v node >/dev/null 2>&1; then
  echo "node is not installed or not in PATH" >&2
  exit 1
fi
if ! command -v npm >/dev/null 2>&1; then
  echo "npm is not installed or not in PATH" >&2
  exit 1
fi

pushd "$PROJECT_PATH" >/dev/null

if [[ -f package-lock.json || -f package.json ]]; then
  if [[ "$SKIP_CI" != true ]]; then
    echo "==> npm ci"
    npm ci
  else
    echo "==> skipping npm ci"
  fi
  echo "==> npm run build"
  npm run build
else
  echo "No package.json found in $PROJECT_PATH" >&2
  popd >/dev/null
  exit 1
fi

if [[ "$RUN_DEV" == true ]]; then
  echo "==> npm run dev (Ctrl+C to stop)"
  npm run dev
fi

popd >/dev/null

echo "Done."
