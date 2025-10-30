---
source_code: https://github.com/drakkan/sftpgo
tags: "files"
---

Create an admin user and a normal user to be able to login with sftp:

```sh
#sftp -P 2022 jalcocert@192.168.1.2
sftp://<username>@192.168.1.2:2022 #sftp://jalcocert@192.168.1.2:2022
```

```sh
#docker run --name some-sftpgo -p 8080:8080 -p 2022:2022 -d "drakkan/sftpgo:tag"
docker run -d \
  --name sftpgo \
  -p 8066:8080 \
  -p 2022:2022 \
  -v /home/jalcocert/Desktop:/srv \
  --restart unless-stopped \
  drakkan/sftpgo:latest
```