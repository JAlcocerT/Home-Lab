---
source_code: https://github.com/umami-software/umami/releases
post: https://fossengineer.com/selfhosting-umami-with-docker/
tag: ["web-analytics","HomeLab Essentials"]
---

`admin///umami`

`sudo docker stats $(docker ps --filter "name=umami" --format "{{.ID}}")`