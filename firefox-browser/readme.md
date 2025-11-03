---
source_code: https://github.com/linuxserver/docker-firefox
tags: "browser"
---


See also: https://github.com/jlesage/docker-firefox/

```sh
docker run -d \
    --name=firefox \
    -p 5800:5800 \
    -v /docker/appdata/firefox:/config:rw \
    jlesage/firefox
```