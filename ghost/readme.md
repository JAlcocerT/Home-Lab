---
source_code: https://github.com/TryGhost/Ghost?ref=fossengineer.com
post: https://fossengineer.com/selfhosting-ghost-docker/
---


```sh
echo -e "MYSQL_DATABASE=ghost\nMYSQL_USER=ghostuser\nMYSQL_PASSWORD=$(openssl rand -base64 32)\nMYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)" > .env
```