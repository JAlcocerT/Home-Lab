---
source_code: https://github.com/traefik/traefik
description: The Cloud Native Application Proxy
official_site: https://traefik.io/
post: https://fossengineer.com/selfhosting-traefik/
---


Thanks to [JimsGarage](https://github.com/JamesTurland/JimsGarage/tree/main/Traefikv3)

```sh
source .env
curl "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer $cf_token"
```

```sh
docker network connect traefik_traefik-proxy portainer
```