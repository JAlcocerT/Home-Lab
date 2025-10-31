#!/bin/bash

set -euo pipefail

# Configurable project name (defaults to my-sample-project)
PROJECT_NAME=${PROJECT_NAME:-my-sample-project}

# Create Strapi app non-interactively with required flags if directory doesn't exist
if [ ! -d "/app/${PROJECT_NAME}" ]; then
  yes | npx create-strapi-app@latest "${PROJECT_NAME}" \
    --quickstart \
    --skip-cloud \
    --no-example
fi

# Ensure JWT secret exists
if [ -f "/app/${PROJECT_NAME}/.env" ] && ! grep -q "^JWT_SECRET=" "/app/${PROJECT_NAME}/.env"; then
  echo "JWT_SECRET=$(openssl rand -base64 32)" >> "/app/${PROJECT_NAME}/.env"
fi

# Run Strapi in develop mode (foreground)
cd "/app/${PROJECT_NAME}"
npm run develop