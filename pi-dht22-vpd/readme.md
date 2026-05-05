---
source_code: https://github.com/JAlcocerT/RPi
tags: IoT
---

```sh
#docker ps | grep emqx
#cd ./RPi/Z_SelfHosting/pgsql
#docker ps | grep timescaledb
cd ./RPi/Z_MicroControllers/RPiPicoW/picow-dht-webapp-vpd-poc
docker compose up -d --build
#Web → http://<host>:8001 · DB → localhost:5433.
docker compose up -d --build webapp
#docker compose up -d #and here it goes timescaleDB + all the webApp
#docker exec -it timescaledb psql -U pico -d sensors
```