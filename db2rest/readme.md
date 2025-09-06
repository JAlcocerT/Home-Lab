---
source_code: https://github.com/9tigerio/db2rest?ref=fossengineer.com
post: 
---

```sh
echo -e "POSTGRES_DB=sampledb\nPOSTGRES_USER=dbuser\nPOSTGRES_PASSWORD=$(openssl rand -base64 32)\nDB_URL=jdbc:postgresql://postgres-db:5432/sampledb\nDB_USER=dbuser\nDB_PASSWORD=$(openssl rand -base64 32)\nDB_DRIVER=org.postgresql.Driver" > .env
```

```sh
docker compose up -d
```