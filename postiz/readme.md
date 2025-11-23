---
source_code: https://github.com/gitroomhq/postiz-app
official_docs:
tags: ["Email Marketing","Social Media"]
---


```sh
#echo -e "JWT_SECRET=$(openssl rand -base64 32)" > .env
cp .env.sample .env

JWT_SECRET=$(openssl rand -base64 32)
echo "JWT_SECRET=$JWT_SECRET" >> .env
echo "Generated: $JWT_SECRET"
```