---
source_code: https://github.com/0xfurai/peekaping/
docs: https://docs.peekaping.com/self-hosting/docker-with-sqlite
tags: ["Monitoring","Status Pages"]
---

```sh
docker run -d --restart=always \
  -p 8383:8383 \
  -e DB_NAME=/app/data/peekaping.db \
  -v $(pwd)/.data/sqlite:/app/data \
  --name peekaping \
  0xfurai/peekaping-bundle-sqlite:latest
```