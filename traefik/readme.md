---
source_code: https://github.com/traefik/traefik
description: The Cloud Native Application Proxy
official_site: https://traefik.io/
post: https://fossengineer.com/selfhosting-traefik/
tags: ["Proxy", "Load Balancer", "Reverse Proxy","HomeLab Essentials"]
---


Thanks to [JimsGarage](https://github.com/JamesTurland/JimsGarage/tree/main/Traefikv3)

```sh
source .env
#verify the token
curl "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer $cf_token"

# Get zone ID via CLI instead of UI
curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=jalcocertech.com" \
  -H "Authorization: Bearer $cf_token" \
  -H "Content-Type: application/json" | jq -r '.result[0].id'
```

```sh
docker network connect traefik_traefik-proxy portainer
```

```sh
ZONE_ID=$(yq -r '.cloudflare.zone_id' cloudflare_config.yaml); \
[ -z "$ZONE_ID" ] || [ "$ZONE_ID" == "null" ] && \
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$(yq -r '.cloudflare.domain_name' cloudflare_config.yaml)" \
  -H "Authorization: Bearer $(yq -r '.cloudflare.api_token' cloudflare_config.yaml)" \
  -H "Content-Type: application/json" | jq -r '.result[0].id'); \
curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  -H "Authorization: Bearer $(yq -r '.cloudflare.api_token' cloudflare_config.yaml)" \
  -H "Content-Type: application/json" | \
jq -r '.result[] | select(.type != "NS" and .type != "MX") | .name' | sort -u
```