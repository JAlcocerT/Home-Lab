---
source_code: https://github.com/danny-avila/LibreChat
container_image: https://github.com/danny-avila/LibreChat/pkgs/container/librechat-dev
---

```sh
git clone https://github.com/danny-avila/LibreChat.git
cd LibreChat

cp .env.example .env
#https://github.com/danny-avila/LibreChat/blob/main/deploy-compose.yml
docker compose up -d
```