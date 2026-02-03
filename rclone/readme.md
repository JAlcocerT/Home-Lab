---
source_code: https://github.com/rclone/rclone
tags: ["cloud_sync","files","Proton Drive"]
---

You can combine rclone+ProtonDrive for sync as found [here](https://blog.otterlord.dev/posts/proton-drive-rclone/).

You could try and backup your nextcloud data folder towards:

1. ProtonDrive: https://rclone.org/protondrive/#configurations

2. Google Drive https://rclone.org/drive/ or https://rclone.org/googlephotos/


I wrote about 

```sh
#sudo apt install rclone

#sudo -v ; curl https://rclone.org/install.sh | sudo bash
#rclone v1.69.2 has successfully installed.
#rclone config

#protondrive
#https://blog.otterlord.dev/posts/proton-drive-rclone/
rclone lsd protondrive: #list all directories, providing that you named the remote also protondrive
rclone lsd protondrive:13-Sync
rclone ls protondrive:x13-Sync

#rclone sync --dry-run <my_remote>:<protondrivedirectory> <localdirectory> -v
rclone sync --dry-run protondrive:x13-Sync /home/jalcocert/Desktop/ProtonDrive -v

rclone sync protondrive:x13-Sync /home/jalcocert/Desktop/ProtonDrive #from cloud to local (one time)
rclone mount protondrive:x13-Sync /home/jalcocert/Desktop/ProtonDrive --vfs-cache-mode full #this makes it bidirectional

#docker run -it -v ~/.config/rclone:/config/rclone  rclone/rclone:beta config
```

Follow the **guidelines**: https://rclone.org/protondrive/#configurations


```sh   
rclone config
```

---

This can also be combined with object storage, like https://rclone.org/s3/#cloudflare-r2 or https://rclone.org/s3/#minio