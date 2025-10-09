---
tags: "Analytics"
---

```sh
git clone https://github.com/apache/superset.git
cd Superset
#docker compose up

git checkout 3.0.0
#git status

TAG=3.0.0 docker compose -f docker-compose-non-dev.yml pull
TAG=3.0.0 docker compose -f docker-compose-non-dev.yml up

#TAG=3.0.0 docker compose -f docker-compose-non-dev.yml up -d
```