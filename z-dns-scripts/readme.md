I've put together a (programatic) way to **modify DNS settings for Cloudflare and Porkbun.**

> All started with scripts, [here](https://github.com/JAlcocerT/waiting-to-landing/blob/main/cloudflare-dns-updater.py) and here [here](https://github.com/JAlcocerT/waiting-to-landing/blob/main/porkbun-domains.py)


```sh
#sudo snap install jq
#sudo snap install yq
# Get Cloudflare zone ID of your domain via CLI instead of Cloudflare UI
curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=jalcocertech.com" \
  -H "Authorization: Bearer $cf_token" \
  -H "Content-Type: application/json" | jq -r '.result[0].id'
```


**Cloudflare**
https://developers.cloudflare.com/api/resources/dns/
https://github.com/cloudflare/cloudflare-python

**Porkbun**
https://porkbun.com/api
## Google Workspace DNS check

Use `google_workspace_dns_check.py` to inspect a domain before connecting it to Google Workspace.

Example:

```sh
python3 google_workspace_dns_check.py getslubnechwile.com
```

What it checks:

- NS records
- MX records
- SPF at the root domain
- DKIM for `google` and `default` selectors by default
- DMARC at `_dmarc.<domain>`

If you want JSON output:

```sh
python3 google_workspace_dns_check.py getslubnechwile.com --json
```

If your DKIM selector is different, repeat `--selector`:

```sh
python3 google_workspace_dns_check.py getslubnechwile.com --selector google --selector mail
```
