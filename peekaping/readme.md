---
source_code: https://github.com/0xfurai/peekaping/
docs: https://docs.peekaping.com/self-hosting/docker-with-sqlite
tags: ["Monitoring","Status Pages"]
---

```sh
# docker run -d --restart=always \
#   -p 8383:8383 \
#   -e DB_NAME=/app/data/peekaping.db \
#   -v $(pwd)/.data/sqlite:/app/data \
#   --name peekaping \
#   0xfurai/peekaping-bundle-sqlite:latest
```

---

Add status badges to your websites as per: https://docs.peekaping.com/badges

**Examples**

![My Local Service Status](http://192.168.1.2:8383/api/v1/badge/1e12dabc-e962-4cd7-b808-ee08c994ec53/status)

Badge Type,Description,Markdown Code
Uptime (30-day),Shows uptime percentage for the last 720 hours.,![Uptime (30d)](http://192.168.1.2:8383/api/v1/badge/1e12dabc-e962-4cd7-b808-ee08c994ec53/uptime/720)
Average Ping,Displays the average response time over the last 24 hours (default).,![Avg Ping](http://192.168.1.2:8383/api/v1/badge/1e12dabc-e962-4cd7-b808-ee08c994ec53/ping)
Certificate Expiry,Shows how many days until the SSL certificate expires (for HTTPS monitors).,![Cert Expiry](http://192.168.1.2:8383/api/v1/badge/04c91562-ba36-4ab2-872c-b4e6daf4067e/cert-exp)
Latest Response,Shows the most recent response time measurement.,![Latest Response](http://192.168.1.2:8383/api/v1/badge/1e12dabc-e962-4cd7-b808-ee08c994ec53/response)