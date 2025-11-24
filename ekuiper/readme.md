---
tags: ["IoT","Automation"]
source_code: https://github.com/lf-edge/ekuiper
---


```sh
docker run -p 9081:9081 -d --name ekuiper -e MQTT_SOURCE__DEFAULT__SERVER=tcp://broker.emqx.io:1883 lfedge/ekuiper:latest
```