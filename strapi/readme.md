---
source_code: https://github.com/strapi/strapi
official_docs: https://strapi.io/blog/how-to-self-host-your-headless-cms-using-docker-compose
tags: ["Headless CMS","OSS for Business","Web"]
---

The most advanced **open-source headless CMS** to build powerful APIs with no effort.

* https://hub.docker.com/r/strapi/strapi/tags
    * https://hub.docker.com/r/strapi/strapi#strapi-base


```sh
docker compose -f docker-compose.yml up -d #http://localhost:1337/admin/auth/register-admin #v3.6.8
#sudo docker logs strapi-strapi-1
```

```sh
#the official images are not updated, so to get the latest use same as with CLI
docker compose -f docker-compose.build.yml up --build

#check manually a sample project
#npx create-strapi@latest
npx create-strapi-app@latest my-sample-project --quickstart #https://docs.strapi.io/dev-docs/installation/cli
#eval 'npx create-strapi-app@latest my-sample-project --quickstart --skip-cloud --no-example'
yes | npx create-strapi-app@latest my-strapi-project --quickstart --skip-cloud --no-example #v5.30.0
```
> `http://localhost:1337/admin`