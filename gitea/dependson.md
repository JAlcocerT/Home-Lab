# depends_on and healthcheck in Docker Compose

- __depends_on__: controls start order and (optionally) waits for dependencies to be healthy before starting a service.
- __healthcheck__: defines how Docker determines whether a container is "healthy" (ready to serve).

## How they relate

- You can gate a service’s startup on a dependency being healthy:
  ```yaml
  services:
    app:
      image: my/app
      depends_on:
        db:
          condition: service_healthy

    db:
      image: mysql:9.0
      healthcheck:
        test: ["CMD-SHELL", "mysqladmin ping -h localhost -u root -p$MYSQL_ROOT_PASSWORD || exit 1"]
        interval: 10s
        timeout: 5s
        retries: 10
        start_period: 10s
  ```
- Compose will start `db` first, run the `healthcheck` inside the `db` container until it reports healthy, then start `app`.

## Your Gitea example

From `gitea/docker-compose.yml`:

```yaml
services:
  gitea-server:
    depends_on:
      gitea-db:
        condition: service_healthy

  gitea-db:
    image: mysql:9.0
    environment:
      - MYSQL_ROOT_PASSWORD=gitea
      - MYSQL_USER=gitea
      - MYSQL_PASSWORD=gitea
      - MYSQL_DATABASE=gitea
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h localhost -u root -p$MYSQL_ROOT_PASSWORD || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 10s
```

- __What it guarantees__: `gitea-server` starts only after MySQL can accept connections.
- __What it does not guarantee__: that app credentials or migrations succeed. The healthcheck proves DB reachability only.

## Tuning tips

- __First boot may be slow__: increase `retries` or `start_period` if MySQL initialization takes longer.
  ```yaml
  healthcheck:
    test: ["CMD-SHELL", "mysqladmin ping -h localhost -u root -p$MYSQL_ROOT_PASSWORD || exit 1"]
    interval: 10s
    timeout: 5s
    retries: 20
    start_period: 30s
  ```
- __Use service name + port__ for the DB host (e.g., `gitea-db:3306`).

## Useful commands

- __See health and status__ (from the project directory):
  ```bash
  docker compose ps
  docker inspect --format '{{json .State.Health}}' <container>
  ```
- __Tail logs__:
  ```bash
  docker compose logs -f --tail 200 gitea-server
  docker compose logs -f --tail 200 gitea-db
  ```

## Summary

- Define a meaningful `healthcheck` on dependencies.
- Use `depends_on: condition: service_healthy` so dependents wait for readiness.
- Tune timings for slow start-ups to avoid false "unhealthy" states.
