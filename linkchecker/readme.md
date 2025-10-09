---
source_code: https://github.com/linkchecker/linkchecker
tags: "web"
---


```sh
# docker run --rm -it -u $(id -u):$(id -g) ghcr.io/linkchecker/linkchecker:latest --verbose https://https://www.psikolognevinkeskin.com/

podman run --rm -it ghcr.io/linkchecker/linkchecker:latest --verbose https://www.psikolognevinkeskin.com/ > linkchecker_psyc.txt
```