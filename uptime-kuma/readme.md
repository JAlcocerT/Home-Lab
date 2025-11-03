---
source_code: https://github.com/louislam/uptime-kuma
post: https://fossengineer.com/selfhosting-uptime-Kuma-docker/
official_docs: https://uptime-kuma-api.readthedocs.io/en/latest/
yt_video: https://www.youtube.com/watch?v=fxVNTffZC2U 
tags: ["web","Status Pages","Monitoring"]
---


Uptime Kuma API: https://github.com/louislam/uptime-kuma/wiki/API-Documentation

---


### Uptime Kuma API

Yes, Uptime Kuma does provide an API, but it is primarily an internal API designed for the application's own use and is not officially supported for third-party integrations. 

It offers a `Socket.io` real-time communication API after authentication and some RESTful API endpoints for tasks like push monitors, status badges, and public status page data.

Using the API (especially through unofficial wrappers like the Python wrapper "uptime-kuma-api"), you can programmatically add new monitors (websites or services) and retrieve some monitoring data.

For example, you can create a new HTTP monitor by specifying the type, name, and URL via the API.[2][3]

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