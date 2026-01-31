---
source_code: https://github.com/alexta69/metube
tags: ["Media","Youtube","Music"]
---

You can try this (Metube) together with a Gonic music server or Jellyfin.


```sh
#git clone https://github.com/JAlcocerT/Home-Lab
#cd ~/Home-Lab/metube
#sudo docker compose up -d

##cd ~/Home-Lab
#git pull
#sudo docker compose -f ./z-homelab-setup/evolution/2601_docker-compose.yml up -d metube

docker ps -a | grep -i metube
#udo docker stats metube #~135mb idle
```

Or use such Desktop App:

```sh
#choco install ytdownloader
sudo snap install ytdownloader
```