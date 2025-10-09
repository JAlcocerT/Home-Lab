---
source_code: https://github.com/dendianugerah/reubah?ref=fossengineer.com
post: 
tags: "Image"
About: "A web-based tool for processing images and converting documents with a simple interface"
---


# Reubah

Reubah is a web interface for managing and monitoring your services. This is based on the [YouTube tutorial](https://www.youtube.com/watch?v=2jftRXvHvlU).

## Quick Start

1. Create a `docker-compose.yml` file with the following content:

```yaml
version: '3.8'

services:
  reubah:
    image: ghcr.io/dendianugerah/reubah:latest
    container_name: reubah
    ports:
      - "8081:8081"
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    restart: unless-stopped
```

2. Start the service:
   ```bash
   docker-compose up -d
   ```

## Access

Access the Reubah web interface at: `http://your-server-ip:8081`

## Security Notes

- The container runs with `no-new-privileges` and drops all Linux capabilities for enhanced security
- The service is configured to automatically restart unless manually stopped

## Volumes

This configuration doesn't include persistent storage by default. If you need to persist any data, consider adding a volume mount to the docker-compose.yml file.

## Updating

To update to the latest version:
```bash
docker-compose pull
docker-compose up -d --force-recreate
```
