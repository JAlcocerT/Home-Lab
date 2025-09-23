---
source_code: https://github.com/baptisteArno/typebot.io
official_docs: https://docs.typebot.io
---

# Typebot Self-Hosted

* https://docs.typebot.io/self-hosting/deploy/docker

## Prerequisites

- Docker and Docker Compose installed
- Ports 3000 (builder) and 3001 (viewer) available

## Setup

1. Create a `.env` file with the following content (generate a secret key first): https://raw.githubusercontent.com/baptisteArno/typebot.io/latest/.env.example

```bash
# Generate this with: openssl rand -base64 24 | tr -d '\n' ; echo
ENCRYPTION_SECRET=your_generated_secret_here

# Database
DATABASE_URL=postgresql://postgres:typebot@typebot-db:5432/typebot

# Authentication (choose one)
# For email/password authentication:
NEXTAUTH_URL=http://localhost:3000
NEXT_PUBLIC_VIEWER_URL=http://localhost:3000
NEXTAUTH_SECRET=your_nextauth_secret_here
```

2. Start the services:

```bash
docker-compose up -d
```

3. Access the Typebot Builder at: http://localhost:3000

## Configuration
- The builder runs on port 3000
- The viewer runs on port 3001
- Database is persisted in a Docker volume

## Updating
To update to the latest version:
```bash
docker-compose pull
docker-compose up -d
```

## Backup
To back up your data:
```bash
# Backup database
docker-compose exec typebot-db pg_dump -U postgres typebot > typebot_backup_$(date +%Y%m%d).sql

# Backup uploads (if any)
tar -czvf typebot_uploads_$(date +%Y%m%d).tar.gz .typebot
```

## Troubleshooting
- Check logs: `docker-compose logs -f`
- If you get database connection errors, ensure the database is healthy before starting other services