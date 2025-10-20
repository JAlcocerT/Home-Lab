#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   cd frappecms
#   export SITE_NAME=${SITE_NAME:-mysite.local}
#   export ADMIN_PASSWORD=${ADMIN_PASSWORD:-change_me_admin}
#   export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-change_me_db_root}
#   ./scripts/init_site.sh
#
# Requires the stack to be up: `docker compose up -d`

SITE_NAME="${SITE_NAME:-${SITE_NAME:-mysite.local}}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-${ADMIN_PASSWORD:-admin}}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-${MYSQL_ROOT_PASSWORD:-root}}"

# Create a new site
docker compose exec -T backend bash -lc \
  "bench new-site ${SITE_NAME} \
     --mariadb-root-password='${MYSQL_ROOT_PASSWORD}' \
     --admin-password='${ADMIN_PASSWORD}' \
     --no-mariadb-socket"

# Set as default site
docker compose exec -T backend bash -lc "bench use ${SITE_NAME} && bench set-default-site ${SITE_NAME} && bench restart"

echo "Site ${SITE_NAME} created. Login at http://192.168.1.11:8089 with Administrator / <your ADMIN_PASSWORD>."
