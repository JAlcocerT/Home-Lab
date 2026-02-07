---
post: https://fossengineer.com/selfhosting-logseq/
source_code: https://github.com/logseq/logseq
official_docs: https://docs.logseq.com/
tags: ["Markdown Notes", "Productivity", "Knowledge Management"]
---

> A privacy-first, open-source platform for knowledge management and collaboration. 

For the container, logseq uses: https://github.com/logseq/logseq/pkgs/container/logseq-webapp


```sh
docker compose -f docker-compose.yml up -d #with traefik
#docker compose -f docker-compose.no-traefik.yml up -d
docker compose -f docker-compose.no-traefik.yml logs
docker inspect logseq-logseq-1 --format '{{ json .Mounts }}' | jq .
#docker compose -f docker-compose.no-traefik.yml exec logseq /bin/sh
docker compose -f docker-compose.no-traefik.yml stop
```

💡 How it works (Logseq Web)

*   **Data Storage:** The Docker container is a static server. Your notes are **not** stored in the container or a Docker volume. They are stored in a local directory on your host machine that you select via the browser.
*   **Browser Memory:** The browser uses the **File System Access API** and stores a "file handle" in its local storage (IndexedDB). 
*   **Offline-capable CSR:** Since it is a **Client-Side Rendered (CSR)** app, once loaded, it runs entirely in your browser's RAM. You can stop the container and keep using Logseq; it only needs the container to *load* or *refresh* the app.
*   **Note:** You need a Chromium-based browser (like Helium) for this to work.

The official support is via desktop: https://github.com/logseq/logseq/releases

```sh
##sudo apt install appimagelauncher
wget -P ~/Applications https://github.com/logseq/logseq/releases/download/0.10.15/Logseq-linux-x64-0.10.15.AppImage
#wget -P ~/Applications https://github.com/imputnet/helium-linux/releases/download/0.8.5.1/helium-0.8.5.1-x86_64.AppImage
```