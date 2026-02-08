---
source_code: https://github.com/baserow/baserow
post: https://baserow.io/docs/installation/install-with-docker-compose
tags: ["Database", "No-code","CRM"]
---

# Baserow Self-Hosting

This folder contains the Docker Compose configuration to self-host Baserow.

Baserow is an open-source, self-hostable no-code database alternative to Airtable. 

It emphasizes native creation and templates, making it suitable for **building CRMs from scratch**. 

In contrast, competitors like NocoDB excel at wrapping existing SQL databases for data import and scaling.

## Key Differences: Baserow vs NocoDB

*   **Baserow**: Offers app builders, real-time collaboration, and 50+ templates. Best for creating new databases and applications.
*   **NocoDB**: Focuses on API speed and integrating with legacy databases. Best for exposing existing data.

## Documentation & Resources

*   **Official Docker Guide**: [Install with Docker](https://baserow.io/docs/installation/install-with-docker)
*   **Docker Compose Guide**: [Install with Docker Compose](https://baserow.io/docs/installation/install-with-docker-compose)
*   **Video Tutorial**: [Installation Video (YouTube)](https://www.youtube.com/watch?v=9QqXHE6Hm_w)
*   **Installation Overview**: [Baserow Installation Docs](https://baserow.io/docs/installation/)
*   **GitHub Repository**: [baserow/baserow](https://github.com/baserow/baserow) (includes docker-compose examples)
*   **Community Discussions**:
    *   [Baserow vs NocoDB (Reddit)](https://www.reddit.com/r/selfhosted/comments/19axu1d/baserow_or_nocodb/)
    *   [Self-Hosting Discussion (Community)](https://community.baserow.io/t/baserow-self-host-self-build-from-source-custom-components-fe-be-build-to-scale-separately/5364)

## Quick Start

### 1. Start the Services
Run the services via Docker Compose in the background:
```bash
docker compose up -d
docker compose logs
```

### 2. Verify the Deployment

Check if all services are running and healthy:

```bash
docker compose ps
```

**Quick Docker Run Command:**

```bash
docker run -d \
  --name baserow \
  -p 80:80 -p 443:443 \
  -e BASEROW_PUBLIC_URL=https://your-domain.com \
  -v baserow_data:/baserow/data \
  --restart unless-stopped \
  baserow/baserow:latest
```

Env vars for external Postgres/OAuth.