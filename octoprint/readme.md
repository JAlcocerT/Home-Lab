---
source_code: https://github.com/OctoPrint/OctoPrint
tags: ["3D printer"]
---

# OctoPrint

Web UI for controlling and monitoring a 3D printer.

```bash
cp .env.sample .env
docker compose up -d
```

Open:

```text
http://192.168.1.2:3818/
```

The first-run wizard creates the admin user; there is no default username or
password. Printer control requires mapping the host USB serial device into the
container. Webcam support requires mapping the video device and enabling
`ENABLE_MJPG_STREAMER=true`.
