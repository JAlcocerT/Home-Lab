---
source_code: https://github.com/hoppscotch/hoppscotch
tags: ["API"]
---


```sh
docker run -d --name hoppscotch -p 3000:3000 --restart=unless-stopped hoppscotch/hoppscotch:latest
```

Or as Hoppscotch as desktop app:

```sh
wget https://github.com/hoppscotch/releases/releases/latest/download/Hoppscotch_linux_x64.deb
sudo apt install ./Hoppscotch_linux_x64.deb #https://hoppscotch.com/download
```