---
source_code: https://github.com/traefik/traefik
description: The Cloud Native Application Proxy
official_site: https://traefik.io/
post: https://fossengineer.com/selfhosting-traefik/
tags: ["Proxy", "Load Balancer", "Reverse Proxy","HomeLab Essentials"]
---


Thanks to [JimsGarage](https://github.com/JamesTurland/JimsGarage/tree/main/Traefikv3)

```sh
#cd traefik
cp .env.sample .env

cp cf-token.sample cf-token ###add your cloudflare token there

source .env #https://dash.cloudflare.com/profile/api-tokens #with edit zone DNS permissions
#verify the token
curl "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer $cf_token"

# Get zone ID via CLI instead of UI (OPTIONAL - only required for programmatic DNS updates)
curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=jalcocertech.com" \
  -H "Authorization: Bearer $cf_token" \
  -H "Content-Type: application/json" | jq -r '.result[0].id'
```

```sh
#cd ./Home-Lab/traefik
touch ./config/acme.json #blank, just change the permissions to 600 later (private key)
#touch ./config/acme.yml
touch ./config/traefik.yml
#touch config/acme.json && chmod 600 config/acme.json
```

```sh
chmod 600 ./config/acme.json && \
chmod 600 ./config/traefik.yml #or it will be a security risk for other users to see the privatekey
```

Point the DNS of the subdomain to the IP of the server:

```sh
docker compose -f docker-compose.x300.yml up -d
#sudo docker logs traefik ###No log line matching the '' filter
#docker-compose -f docker-compose.x300.yml stop
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