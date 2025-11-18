---
source_code: https://github.com/crazymax/fail2ban
post: https://fossengineer.com/setup-fail2ban-with-docker/
tags: ["Security"]
---




<!-- 

### How to expose services Safely with Fail2Ban

{{< dropdown title="Use Fail2Ban 🐋 Container with NGINX 👇" closed="true" >}}

Use Fail2Ban with NGINX with this docker-compose:

```yml
version: '2'
services:
  fail2ban:
    image: crazymax/fail2ban:latest
    restart: unless-stopped
    network_mode: "host"
    cap_add:
    - NET_ADMIN
    - NET_RAW
    volumes:
    - /var/log:/var/log:ro
    - ~/Docker/fail2ban/data:/data
    env_file:
      - ./fail2ban.env
```

{{< /dropdown >}}

#### Fail2Ban :heavy_check_mark:

```
wget  -cO - https://raw.githubusercontent.com/jalcocert/docker/main/Security/fail2ban > f2b.sh && chmod 775 f2b.sh && sudo ./f2b.sh
```

```
 #fail2ban
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg2 \
vim \
fail2ban \
ntfs-3g
```

```
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local && #copying it to edit
sudo nano /etc/fail2ban/jail.local
```

Add this to the file to ban for 24h if retry +3 times:


Copy
```
bantime = 86400
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = 3
```
```
sudo service fail2ban restart &&
sudo nano /var/log/fail2ban.log
```

https://geekland.eu/instalar-configurar-y-usar-fail2ban-para-evitar-ataques-de-fuerza-bruta/

```
#!/bin/sh

#wget  -cO - https://raw.githubusercontent.com/reisikei/docker/main/Security/fail2ban > f2b.sh && chmod 775 f2b.sh && sudo ./f2b.sh

mkdir Docker
cd Docker
mkdir fail2ban
cd fail2ban
wget  -cO - https://raw.githubusercontent.com/reisikei/docker/main/Security/fail2ban_docker-compose.yaml > docker-compose.yaml
sudo docker-compose up -d
``` -->
