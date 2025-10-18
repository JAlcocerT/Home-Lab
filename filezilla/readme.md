#https://filezilla-project.org

---
#version: "2.1"
services:
  filezilla:
    image: lscr.io/linuxserver/filezilla:latest
    container_name: filezilla
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /home/Docker/filezilla/config:/config
    ports:
      - 3000:3000
      - 3001:3001
    restart: unless-stopped