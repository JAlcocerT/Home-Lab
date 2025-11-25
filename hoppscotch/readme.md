---
source_code: https://github.com/hoppscotch/hoppscotch
tags: ["API","IoT"]
---


```sh
docker run -d --name hoppscotch -p 3000:3000 --restart=unless-stopped hoppscotch/hoppscotch:latest
```

Or as Hoppscotch as desktop app:

```sh
wget https://github.com/hoppscotch/releases/releases/latest/download/Hoppscotch_linux_x64.deb
sudo apt install ./Hoppscotch_linux_x64.deb #https://hoppscotch.com/download
```

---

**See also** these desktop apps:

1. https://github.com/httpie/desktop

```sh
#sudo apt install appimagelauncher
wget -P ~/Applications https://github.com/httpie/desktop/releases/download/v2025.2.0/HTTPie-2025.2.0.AppImage
#httpie
```

>  🚀 HTTPie Desktop — cross-platform API testing client for humans. Painlessly test REST, GraphQL, and HTTP APIs. 

2. Reqable - Reqable implements the core features of traffic analysis and **API testing**, and deeply integrates them. 

One app is worth multiple apps: Advanced API Debugging Proxy and REST Client

> [Reqable](https://github.com/reqable/reqable-app) = Fiddler + Charles + Postman

```sh
flatpak install flathub com.reqable.Reqable
```


3. https://github.com/mountain-loop/yaak/

>  MIT | The most intuitive **desktop API client**.

> > Organize and execute **REST, GraphQL, WebSockets, Server Sent Events (SSE), and gRPC** 🦬 
