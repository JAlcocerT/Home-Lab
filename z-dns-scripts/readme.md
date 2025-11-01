I put together a (programatic) way to **modify DNS settings for Cloudflare and Porkbun.**

All started with scripts, [here](https://github.com/JAlcocerT/waiting-to-landing/blob/main/cloudflare-dns-updater.py) and here [here](https://github.com/JAlcocerT/waiting-to-landing/blob/main/porkbun-domains.py)


```sh
#sudo snap install jq
#sudo snap install yq
# Get Cloudflare zone ID of your domain via CLI instead of Cloudflare UI
curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=jalcocertech.com" \
  -H "Authorization: Bearer $cf_token" \
  -H "Content-Type: application/json" | jq -r '.result[0].id'
```