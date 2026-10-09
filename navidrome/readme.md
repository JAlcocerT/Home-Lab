---
source_code: https://github.com/navidrome/navidrome
oss_client: https://gitlab.com/ultrasonic/ultrasonic
tags: ["Music Server","Media Server"]
---

For Android, look for: [Ultrasonic](https://github.com/ultrasonic/ultrasonic) which moved [here](https://gitlab.com/ultrasonic/ultrasonic).

For IoS, look for [Amperfy](https://github.com/BLeeEZ/amperfy)

For desktop: [Feishin](https://github.com/JAlcocerT/Home-Lab/tree/main/feishin).

---

```sh
# Stop container (if running)
sudo docker compose down

# Create host directories
mkdir -p ./data ./backups
mkdir -p /path/to/your/music

# Create local config
cp .env.sample .env
# Edit NAVIDROME_MUSIC_PATH before first boot.

# Ensure UID:GID 1000:1000 can write data/backups and read music
sudo chown -R 1000:1000 ./data ./backups

# (Optional) permissions
chmod -R u+rwX,go-rwx ./data ./backups
chmod -R u+rX,go-rwx /path/to/your/music

# Start again
sudo docker compose up -d
```
