

```sh
docker compose -f docker-compose.yml up -d
#docker network connect cloudflared_tunnel pocketbase
#docker inspect pocketbase --format '{{range $k,$v := .NetworkSettings.Networks}}{{println $k}}{{end}}'
```

Login to admin via: `http://192.168.1.11:8080/_/?installer#`