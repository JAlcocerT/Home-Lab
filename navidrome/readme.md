---
source_code: https://github.com/deluan/navidrome
oss_client: https://gitlab.com/ultrasonic/ultrasonic
---

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