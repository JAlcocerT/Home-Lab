---
source_code: https://github.com/listmonk/listmonk
tags: ["Email Marketing","OSS for Business"]
---



```sh
# Download the compose file to the current directory.
curl -LO https://github.com/knadh/listmonk/raw/master/docker-compose.yml

# Run the services in the background.
docker compose up -d
#docker compose logs -f app
```

> Go to `http://localhost:9077` to access the web app.

> > Use it together with proper email SMTP [as per this post](https://jalcocert.github.io/JAlcocerT/emails-101/)