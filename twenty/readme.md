---
source_code: https://github.com/twentyhq/twenty
tags: ["CRM","OSS for business"]
---

# TwentyCRM Self-Hosting

This folder contains the Docker Compose configuration to self-host TwentyCRM.

* https://hub.docker.com/r/twentycrm/twenty/tags
    * https://hub.docker.com/v2/repositories/twentycrm/twenty/tags
* https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/scripts/install.sh

TwentyCRM is an open-source CRM designed to be extensible and developer-friendly.

## Setup Instructions

We've manually replicated the steps from the [official setup script](https://raw.githubusercontent.com/twentyhq/twenty/main/packages/twenty-docker/setup.sh) to ensure control over the configuration.

### 1. Configuration (.env)

The `.env` file has been pre-configured with:
- **TAG**: `v0.39.0` (Latest stable release at setup time)
- **Secrets**: Generated securely using `openssl`.
- **Port**: `3000` (Default)

If you need to regenerate secrets:
```bash
openssl rand -base64 32 # for APP_SECRET
openssl rand -hex 32    # for PG_DATABASE_PASSWORD
```

### 2. Start Services

```bash
docker compose up -d
```

### 3. Access

Open your browser at `http://localhost:3000` and enjoy TwentyCRM!

## Script Logic (Reference)

The official setup script performs the following actions, which we have done manually:
1.  **Dependency Check**: Verifies Docker and Docker Compose are installed.
2.  **Version Check**: Fetches the latest version tag from GitHub.
3.  **Download**: Retrieves `docker-compose.yml` and `.env.example`.
4.  **Configuration**:
    -   Generates `APP_SECRET` and `PG_DATABASE_PASSWORD`.
    -   Sets `TAG` to the latest version.
    -   Checks for port availability (defaults to 3000).
