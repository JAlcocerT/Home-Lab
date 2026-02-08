---
source_code: https://github.com/AppFlowy-IO/AppFlowy
post: https://docs.appflowy.io/docs/appflowy-cloud/self-hosting/docker
tags: ["Workspace", "Productivity"]
---

Bring projects, wikis, and teams together with AI

# AppFlowy Self-Hosting

This folder contains the Docker Compose configuration to self-host AppFlowy Cloud.

## Setup and Deployment

### 1. Clone the AppFlowy-Cloud Repository
```bash
git clone https://github.com/AppFlowy-IO/AppFlowy-Cloud.git
```

### 2. Configure Environment Variables
From the root of the directory, copy `deploy.env` to `.env`.
```bash
cp deploy.env .env
```

**(Optional) Custom Port Bindings**
If port 80 or 443 are already occupied by another service (like another Nginx instance), modify the port binding in your `.env` file:

```bash
NGINX_PORT=80
NGINX_TLS_PORT=443
```

### 3. Start the Services

Run the services via Docker Compose in the background:

```bash
docker compose up -d
```

### 4. Verify the Deployment

Check if all services are running and healthy:

```bash
docker compose ps
```

## Resources and Documentation
* [Local Host Deployment](https://appflowy.com/docs/Local-Host-Deployment)
* [AppFlowy Cloud Self-Hosting Guide](https://docs.appflowy.io/docs/guides/appflowy)
* [How to install AppFlowy Cloud using Coolify](https://appflowy.com/docs/How-to-install-AppFlowyCloud-using-Coolify)

### AppFlowy Desktop

You can download the desktop application here: [AppFlowy Download](https://appflowy.com/download)

AppImage releases: [AppFlowy GitHub Releases](https://github.com/AppFlowy-IO/AppFlowy/releases)