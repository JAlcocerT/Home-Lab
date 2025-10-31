---
source_code: https://github.com/sentriz/gonic
tags: ["Music Server","Media Server"]
---

```sh
#docker compose up -d
docker compose -f ./gonic/docker-compose.traefik.yml up -d
#docker logs --tail=200 -f gonic
#docker compose -f ./gonic/docker-compose.traefik.yml logs --tail=200 -f
#docker stop gonic
```

Default credentials are `admin/admin`.

Alternatively, see [Polaris](https://github.com/agersant/polaris) or Navidrome.

For Android, look for: [Ultrasonic](https://github.com/ultrasonic/ultrasonic) which moved [here](https://gitlab.com/ultrasonic/ultrasonic)

For IoS, look for [Amperfy](https://github.com/BLeeEZ/amperfy)

For Desktop, see [Sonixd](https://github.com/jeffvli/sonixd/releases/tag/v0.15.5)

```sh
#winget install sonixd
wget -P ~/Applications https://github.com/jeffvli/sonixd/releases/download/v0.15.5/Sonixd-0.15.5-linux-x86_64.AppImage
```