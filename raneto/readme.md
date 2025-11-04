---
source_code: https://github.com/raneto/raneto
post: https://fossengineer.com/raneto-markdown-knowledgebase-selfhosting/
tags: "Notes"
---

# Raneto Self-Hosted Knowledge Base

This is a self-hosted instance of Raneto, a knowledge base platform that uses Markdown files for content.

## Prerequisites

- Docker
- Docker Compose

## Getting Started

1. Clone this repository
2. Navigate to the project directory
3. Start the containers:

```bash
docker-compose up -d
```
4. Access the application at http://localhost:3000

## Configuration

- The main configuration file is `config.js`
- All your Markdown files should be placed in the `content` directory
- The default admin credentials are:
  - Username: admin
  - Password: password

## Backing Up

To back up your knowledge base, simply back up the `content` directory.

## Updating

To update to the latest version of Raneto, run:

```bash
docker-compose pull
# If you want to rebuild the container with new settings
docker-compose up -d --force-recreate
```

## Security Notes

1. Change the default admin credentials after first login
2. Update the `token_secret` in `config.js` to a secure random string
3. Consider enabling HTTPS using a reverse proxy like Nginx or Traefik
