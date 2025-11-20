---
source_code: https://github.com/fosrl/pangolin
post: https://fossengineer.com/selfhosting-pangolin-cloudflared-tunnel-alternative/
---

See also 

1. https://github.com/localtunnel/server - *localtunnel exposes your localhost to the world for easy testing and sharing! No need to mess with DNS or deploy just to have others test out your changes.*

> Thanks to https://noted.lol/pangolin/


* https://github.com/fosrl/pangolin
    * https://docs.fossorial.io/

> Tunneled Mesh Reverse Proxy Server with Identity and Access Control and Dashboard UI


<!-- 
https://www.youtube.com/watch?v=a-a-Xk1hXBQ&t=402s 
-->

{{< youtube "a-a-Xk1hXBQ" >}}

https://docs.fossorial.io/Newt/install

To the home server yo use:

```yml
services:
    newt:
        image: fosrl/newt
        container_name: newt
        restart: unless-stopped
        environment:
            - PANGOLIN_ENDPOINT=https://example.com
            - NEWT_ID=2ix2t8xk22ubpfy
            - NEWT_SECRET=nnisrfsdfc7prqsp9ewo1dvtvci50j5uiqotez00dgap0ii2
```

Pangolin. Compared with other https tools like Cloudflared, Caddy, Traefik and NGINX.
Pangolin: Your Own Self-Hosted Cloudflare Tunnel Alternative

Watch the Video
Overview

This report summarizes a YouTube video by DB Tech that discusses Pangolin, a self-hosted alternative to Cloudflare Tunnels. Pangolin provides remote access to self-hosted resources without requiring port forwarding and offers various authentication methods for resources. The video goes through the installation requirements, Pangolin overview, site and resource setup, authentication setup, and site and resource connection.
Section 1: Introduction

Pangolin is a self-hosted alternative to Cloudflare Tunnels that allows remote access to self-hosted resources without port forwarding. It is still in beta and requires a domain name and access to another Docker server outside the home.
Section 2: Installation Requirements

Pangolin requires a domain name and access to another Docker server outside the home. The installation process involves changing the DNS record for the domain and installing Pangolin using the installer script or using the manual install method.
Section 3: Pangolin Overview

Pangolin uses Gerbil for reverse proxying, Traffic for TLS termination, Badger as a plugin for Traffic, and Newt as the tunnel agent installed locally.
Section 4: Site and Resource Setup

Sites are used to create tunnels, and resources include applications running on the network. The video demonstrates adding a Hortus Fox and Excalidraw resource.
Section 5: Authentication Setup

Pangolin offers authentication methods for resources, including platform SSO, password protection, pin code, and one-time passwords. The video demonstrates setting up these authentication methods for a resource.
Section 6: Site and Resource Connection

A site and resource are connected by installing the Newt agent on the local node using a Docker Compose file.
Takeaways

Pangolin allows remote access to **self-hosted resources without port forwarding.**
It provides various authentication methods for resources.
Pangolin **requires a domain name and access to another Docker server outside the home**.
Site and resource connection is established by installing the Newt agent on the local node.

Report generated on: February 18, 2025 (11:29 AM)

# Pangolin - Self-Hosted Deployment

[Pangolin](https://github.com/fosrl/pangolin) is a self-hosted web application for managing and monitoring your services.

## Features
- Simple web interface
- Service monitoring
- Easy deployment with Docker
- Lightweight and fast

## Prerequisites
- Docker
- Docker Compose

## Quick Start

1. **Clone the repository** (if not already done):
   ```bash
   git clone https://github.com/yourusername/your-repo.git
   cd pangolin
   ```

2. **Create a `.env` file** (optional):
   ```bash
   cp .env.example .env
   # Edit the .env file with your configuration
   ```

3. **Start Pangolin**:
   ```bash
   docker-compose up -d
   ```

4. **Access the Web UI**:
   - Open your browser and go to: `http://your-server-ip:3000`

## Configuration

### Environment Variables

Create a `.env` file in the project root with your configuration:

```env
# Application
NODE_ENV=production
PORT=3000

# Database (if using PostgreSQL)
# DATABASE_URL=postgres://user:password@postgres:5432/pangolin
```

### Volumes
- `./data` - Application data directory

### Ports
- `3000` - Web UI port (change if needed in `docker-compose.yml`)

## Using PostgreSQL (Optional)

1. Uncomment the PostgreSQL service in `docker-compose.yml`
2. Update the database configuration in your `.env` file
3. Restart the services:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

## Updating

To update to the latest version:

```bash
docker-compose pull
docker-compose up -d --force-recreate
```

## Backup and Restore

### Backup
```bash
# Backup application data
tar -czvf pangolin_backup_$(date +%Y%m%d).tar.gz ./data

# If using PostgreSQL
docker exec pangolin-db pg_dump -U pangolin pangolin > pangolin_db_backup_$(date +%Y%m%d).sql
```

### Restore
```bash
# Stop the services
docker-compose down

# Restore application data
tar -xzvf pangolin_backup_YYYYMMDD.tar.gz -C ./

# If using PostgreSQL
cat pangolin_db_backup_YYYYMMDD.sql | docker exec -i pangolin-db psql -U pangolin

# Start the services
docker-compose up -d
```

## Troubleshooting

### View Logs
```bash
docker-compose logs -f
```

### Reset Application
1. Stop and remove containers:
   ```bash
   docker-compose down -v
   ```
2. Remove the data directory:
   ```bash
   rm -rf ./data
   ```
3. Start fresh:
   ```bash
   docker-compose up -d
   ```

## Security
- Change default credentials if any
- Use a reverse proxy with HTTPS in production
- Regularly update to the latest version

## License
Pangolin is open source. See the [GitHub repository](https://github.com/fosrl/pangolin) for license information.

## References
- [GitHub Repository](https://github.com/fosrl/pangolin)
- [Documentation](https://github.com/fosrl/pangolin#readme)
