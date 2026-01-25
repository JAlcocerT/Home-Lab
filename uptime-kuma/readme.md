---
source_code: https://github.com/louislam/uptime-kuma
post: https://fossengineer.com/selfhosting-uptime-Kuma-docker/
official_docs: https://uptime-kuma-api.readthedocs.io/en/latest/
yt_video: https://www.youtube.com/watch?v=fxVNTffZC2U 
tags: ["web","Status Pages","Monitoring"]
---

The user and pwd is created during the first run: `http://192.168.1.2:3001/setup-database`

```sh
# Default (Development)
docker compose up -d

# Production
docker compose -f docker-compose.prod.yml up -d

# Stop and Remove (via Compose)
docker compose down
# OR (for prod)
docker compose -f docker-compose.prod.yml down

# Stop and Remove (via Container Name)
docker stop uptimekuma
docker rm uptimekuma
```

See also:

* https://github.com/louislam/uptime-kuma/wiki/3rd-Party-Addons-Apps
* https://github.com/louislam/uptime-kuma/wiki/Badge

---


### Uptime Kuma API

Uptime Kuma API: https://github.com/louislam/uptime-kuma/wiki/API-Documentation

* https://uptime-kuma-api.readthedocs.io/en/latest/

## API Automation (Python)

To add monitors programmatically, you can use the Python script:

```bash
# 1. Install the library
uv init
#pip install uptime-kuma-api
uv add uptime-kuma-api

# 2. Edit the script with your credentials
# nano scripts/add_monitor.py

# 3. Run it
#python3 scripts/add_monitor.py
uv run scripts/add_monitor.py
```

Uptime Kuma does provide an API, but it is primarily an internal API designed for the application's own use and is not officially supported for third-party integrations. 

It offers a `Socket.io` real-time communication API after authentication and some RESTful API endpoints for tasks like push monitors, status badges, and public status page data.

Using the API (especially through unofficial wrappers like the Python wrapper "uptime-kuma-api"), you can programmatically add new monitors (websites or services) and retrieve some monitoring data.

For example, you can create a new HTTP monitor by specifying the type, name, and URL via the API.

The API allows you to:

- Post new websites or services to monitor.
- Retrieve their status and monitoring data.
- Access real-time updates through Socket.io.
- Get status badges or integrate with Prometheus metrics.
  
However, the official API is somewhat limited and not guaranteed to be stable or fully documented for external use, so use it with caution.

In summary:

- You can add monitors programmatically.
- You can retrieve monitoring data (status, alerts).
- The API is mostly internal and unofficial but functional.
- There are third-party wrappers to help interact with it.