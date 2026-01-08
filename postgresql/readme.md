---
source_code: https://github.com/postgres/postgres
official_docs: https://www.postgresql.org/docs/16/index.html
---

Selfhost PGsql as an alternative to cloud services, as commented [here](https://jalcocert.github.io/JAlcocerT/creating-a-diy-paas-service/#selfhost-postgres).

```sh
docker compose up -d
#sudo docker compose logs
#sudo docker compose stop
```

Used to create a DIY plug and play db analytics via rag around [this repo](https://github.com/JAlcocerT/langchain-db-ui).

```sh
#docker stop $(docker ps -a -q) #stop all
#docker system df
#docker system prune -a --volumes -f
```