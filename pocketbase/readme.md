---
source_code: https://github.com/pocketbase/pocketbase
official_docs: https://pocketbase.io/docs
tags: ["Dev","BaaS"]
---



```sh
docker compose -f docker-compose.yml up -d

#docker network connect cloudflared_tunnel pocketbase
#docker inspect pocketbase --format '{{range $k,$v := .NetworkSettings.Networks}}{{println $k}}{{end}}'
```

Login to admin via: `http://192.168.1.11:8080/_/?installer#`

---

```sh
#sudo docker build -t pocketbase .
docker run -d \
  --name pocketbase \
  --restart=unless-stopped \
  -p 8080:8080 \
  -v ./pb-test2:/pb/pb_data \
  -e POCKETBASE_URL=http://192.168.1.12:8080 \
  pocketbase:latest
#   -e POCKETBASE_ADMIN_EMAIL=admin@example.com \
#   -e POCKETBASE_ADMIN_PASSWORD=admin123 \

#docker stats pocketbase
#curl -f http://localhost:8080/api/health
#docker stop pocketbase
#docker rm pocketbase
```