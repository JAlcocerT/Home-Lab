---
source_code: https://github.com/TryGhost/Ghost?ref=fossengineer.com
post: https://fossengineer.com/selfhosting-ghost-docker/
tags: ["web","CMS"]
---

> Thanks to [noted.lol](https://noted.lol/self-host-ghost)

```sh
echo -e "MYSQL_DATABASE=ghost\nMYSQL_USER=ghostuser\nMYSQL_PASSWORD=$(openssl rand -base64 32)\nMYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)" > .env
```

Ghost can be used as a CMS for static sites, like Gatsby.

## Ghost Themes

* {{< newtab url="https://ghost.org/themes/alto" text="Free theme alto in Ghost Official Page." >}}
* {{< newtab url="https://ghost.org/themes/edge" text="Free theme edge in Ghost Official Page." >}}
* {{< newtab url="https://ghost.org/themes/headline/" text="Free theme headline in Ghost Official Page." >}}
* {{< newtab url="https://github.com/TryGhost/Solo" text="Solo theme in GitHub." >}}
* {{< newtab url="https://github.com/godofredoninja/Paway" text="Paway theme in GitHub." >}}

## API Guide

For a comprehensive guide on interacting with Ghost's APIs (Content API and Admin API), including how to obtain keys, authentication methods, and example requests (curl and JavaScript), see:

- [API.md](./API.md)

The instance in this compose is exposed at `http://192.168.1.8:8018` (mapped to container port `2368`). If you are testing locally on the same machine, `http://localhost:8018` may also work depending on your network.