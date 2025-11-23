---
source_code: https://github.com/listmonk/listmonk
tags: ["Email Marketing","OSS for Business"]
official_docs: https://listmonk.app/docs/configuration/
---



```sh
# Download the compose file to the current directory.
curl -LO https://github.com/knadh/listmonk/raw/master/docker-compose.yml

# Run the services in the background.
docker compose up -d
#docker compose logs -f app
###docker network connect cloudflared_tunnel listmonk_app #add listmonk_app:9000 via CF UI
```

> Go to `http://localhost:9077` to access the web app.

> > Use it together with proper email SMTP [as per this post](https://jalcocert.github.io/JAlcocerT/emails-101/) and if needed, import email leads from your custom tools like [this](https://github.com/JAlcocerT/simple-waiting-list)

---

See `./listmonk-api-py/README.md` for more info on how to use the API to interact programatically with Listmonk.

But what it worked for me was `./listmonk-subscribe` which uses the NEXTjs endpoints: 

```sh
curl -s https://listmonk.jalcocertech.com/api/public/lists | jq
#npm run dev


# create subscriber
curl -u 'apiuser:ACCESS_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "yosua@some.domain",
    "name": "Jane Doe",
    "status": "enabled",
    "list_uuids": ["7fbcb72b-cc0a-4a31-a196-bdc847d55ea5"]
  }' \
  https://listmonk.jalcocertech.com/api/subscribers
```