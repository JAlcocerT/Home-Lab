---
post: 
tags: ["remote desktop"]
source_code: https://github.com/boschkundendienst/guacamole-docker-compose
---



<!-- 
Interested to discover similar services that you can self-host with Docker? - Check this out:

{{< gist jalcocert cf73aed383470d8764642499f034d5dc
"Docker-Backups-ConfigFiles">}} -->

<!-- ---

## FAQ

### F/OSS FTP Server

* https://hub.docker.com/r/panubo/vsftpd/
  use it with filezilla or directly in ubuntu file manager
* https://www.filestash.app/

### F/OSS NAS

### other monitoring tools

* remotely
* lxconsole

### managing windows pcs 

* meshcentral

### How to SelfHost Guacamole

* https://github.com/boschkundendienst/guacamole-docker-compose

```sh
git clone "https://github.com/boschkundendienst/guacamole-docker-compose.git"
cd guacamole-docker-compose
./prepare.sh
docker-compose up -d
```

Dont forget!: sudo docker-compose up -d

* Go to https://localhost:8443

accept the risk and continue.


https://github.com/oznu/docker-guacamole
https://hub.docker.com/r/oznu/guacamole/

docker run \
  -p 8080:8080 \
  -v /home/Docker/Guacamole/config:/config \
  oznu/guacamole


```yml
version: '3.3'
services:
  guacamole:
    image: oznu/guacamole
    ports:
      - "8037:8080"
    volumes:
      - /home/Docker/guacamole/config>:/config
    environment:
      - EXTENSIONS=auth-ldap,auth-duo
    restart: unless-stopped

``` -->

<!-- 

```yml
version: '3'
services:
  guacd:
    image: guacamole/guacd
    restart: always
    ports:
      - "4822:4822"

  guacamole:
    image: guacamole/guacamole
    restart: always
    ports:
      - "8080:8080"
    environment:
      GUACD_HOSTNAME: guacd
      MYSQL_HOSTNAME: db
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacamole_user
      MYSQL_PASSWORD: guacamole_password
    depends_on:
      - guacd
      - db

  db:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: guacamole_db
      MYSQL_USER: guacamole_user
      MYSQL_PASSWORD: guacamole_password
    volumes:
      - guacamole_db:/var/lib/mysql

volumes:
  guacamole_db:

``` -->

* User and pass: `guacadmin/guacadmin`