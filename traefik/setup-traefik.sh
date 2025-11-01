#!/usr/bin/env bash
set -euo pipefail

# Setup script to prepare and start Traefik using docker-compose.x300.yml
# - Ensures required files exist
# - Applies correct permissions
# - Prompts to confirm DNS is configured
# - Starts Traefik

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$here"

compose_file="docker-compose.x300.yml"
config_dir="$here/config"
acme_file="$config_dir/acme.json"
traefik_cfg="$config_dir/traefik.yaml"
config_yaml="$config_dir/config.yaml"
cf_secret="$here/cf-token"
env_file="$here/.env"

# 1) Sanity checks
command -v docker >/dev/null 2>&1 || { echo "Error: docker is not installed or not in PATH" >&2; exit 1; }
if ! docker compose version >/dev/null 2>&1; then
  echo "Error: Docker Compose CLI (docker compose) is not available." >&2
  exit 1
fi

[ -f "$compose_file" ] || { echo "Error: $compose_file not found in $here" >&2; exit 1; }
[ -d "$config_dir" ] || { echo "Error: config directory not found at $config_dir" >&2; exit 1; }

# 2) Ensure acme.json exists and has strict perms
if [ ! -f "$acme_file" ]; then
  echo "Creating $acme_file"
  echo '{}' > "$acme_file"
fi
chmod 600 "$acme_file"

# 3) Ensure main config files exist (copy from samples if present)
if [ -d "$traefik_cfg" ]; then
  echo "Error: $traefik_cfg is a directory. It must be a file." >&2
  exit 1
fi
if [ ! -f "$traefik_cfg" ] && [ -f "$config_dir/traefik.sample.yaml" ]; then
  echo "Creating $traefik_cfg from sample"
  cp "$config_dir/traefik.sample.yaml" "$traefik_cfg"
fi

if [ -d "$config_yaml" ]; then
  echo "Error: $config_yaml is a directory. It must be a file." >&2
  exit 1
fi
# Prefer existing config.yaml; otherwise seed from a sample if available
if [ ! -f "$config_yaml" ]; then
  if [ -f "$config_dir/config.casasample.yaml" ]; then
    echo "Creating $config_yaml from config.casasample.yaml"
    cp "$config_dir/config.casasample.yaml" "$config_yaml"
  elif [ -f "$config_dir/config.sample.yaml" ]; then
    echo "Creating $config_yaml from config.sample.yaml"
    cp "$config_dir/config.sample.yaml" "$config_yaml"
  else
    echo "Warning: $config_yaml does not exist and no sample was found. Continuing." >&2
  fi
fi

# 4) Warn if secrets/env are missing
if [ ! -f "$cf_secret" ]; then
  echo "Warning: Secret file $cf_secret is missing. DNS challenge may fail." >&2
fi
if [ ! -f "$env_file" ]; then
  echo "Warning: Env file $env_file is missing. Dashboard auth and variables may be unset." >&2
fi

# 5) Confirm DNS is ready before issuing certs
cat <<'EOT'
Before starting Traefik, ensure DNS is set:
- x300.jalcocertech.com -> your Traefik host IP
- *.x300.jalcocertech.com -> your Traefik host IP (optional wildcard)
Or ensure your Cloudflare DNS API token/secret is configured for DNS challenge.
EOT

read -r -p "Have you pointed the DNS records properly (y/N)? " ans
ans=${ans:-N}
if [[ ! "$ans" =~ ^[Yy]$ ]]; then
  echo "Aborting. Please configure DNS first, then re-run this script."
  exit 2
fi

# 6) Start Traefik
echo "Starting Traefik with $compose_file ..."
docker compose -f "$compose_file" up -d traefik

echo "\nDone. Useful checks:"
echo "- docker logs -f traefik"
echo "- Traefik dashboard: https://x300.jalcocertech.com (with your auth)"
