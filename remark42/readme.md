---
source_code: https://github.com/umputun/remark42
tags: ["Web","Commenting System"]
official_docs: https://remark42.com/docs/getting-started/installation/
---

<!-- https://github.com/umputun/remark42/blob/master/docker-compose.yml
https://hub.docker.com/r/umputun/remark42

https://www.devbitsandbytes.com/setting-up-remark42-from-scratch/ -->

Create a secret:

```sh
openssl rand -base64 32
```

Add to Cloudflare Network: `https://remark42.whateverdomain.com/web/`

It integrates perfectly with [Astro SSG](https://github.com/JAlcocerT/Home-Lab/tree/main/ssg-astro) or [HUGO](https://github.com/JAlcocerT/Home-Lab/tree/main/ssg-astro): https://remark42.com/docs/manuals/integration-with-astro/

To add it to every post,  you need to find the **single.html**, somewhere around `/layouts/_default/...`

> See also [Commento](https://github.com/JAlcocerT/Home-Lab/tree/main/commento)