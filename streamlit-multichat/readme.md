---
source_code: https://github.com/JAlcocerT/Streamlit-MultiChat
---



The .dev version is for local development and will require a local container build.

```sh
git clone https://github.com/JAlcocerT/Streamlit-MultiChat.git
docker compose -f docker-compose.dev.yml up -d #use this for local development with local container build
```

For production, you can use the estable version [pushed to ghcr](https://github.com/JAlcocerT/Streamlit-MultiChat/pkgs/container/streamlit-multichat) with the .traefik or *nginx/cloudflare* .portainer configuration.

```sh
docker pull ghcr.io/jalcocert/streamlit-multichat:latest #x86/ARM64
```

```sh
#sudo docker compose -f docker-compose.portainer.yml up -d
sudo docker compose -f docker-compose.traefik.yml up -d
#nslookup multichat.jalcocertech.com
#sudo docker compose -f docker-compose.traefik.yml down
```