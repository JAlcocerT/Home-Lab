---
source_code: https://github.com/deluan/navidrome
oss_client: https://gitlab.com/ultrasonic/ultrasonic
tags: ["Music Server","Media Server"]
---

For Android, look for: [Ultrasonic](https://github.com/ultrasonic/ultrasonic) which moved [here](https://gitlab.com/ultrasonic/ultrasonic).

For IoS, look for [Amperfy](https://github.com/BLeeEZ/amperfy)

For desktop: [Aonsoku](https://github.com/victoralvesf/aonsoku) 

See also https://github.com/betsha1830/navispot to  Export Spotify playlists to Navidrome. 

---

```sh
# Stop container (if running)
sudo docker compose down

# Create host directories
mkdir -p /home/jalcocert/Home-Lab/navidrome/data
mkdir -p /home/jalcocert/Home-Lab/navidrome/music   # adjust if your music is elsewhere

# Ensure UID:GID 1000:1000 owns them
sudo chown -R 1000:1000 /home/jalcocert/Home-Lab/navidrome/data
sudo chown -R 1000:1000 /home/jalcocert/Home-Lab/navidrome/music

# (Optional) permissions
chmod -R u+rwX,go-rwx /home/jalcocert/Home-Lab/navidrome/data
chmod -R u+rX,go-rwx /home/jalcocert/Home-Lab/navidrome/music

# Start again
sudo docker compose up -d
```