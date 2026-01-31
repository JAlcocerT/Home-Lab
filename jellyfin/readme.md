---
source_code: https://github.com/jellyfin/jellyfin
tags: ["Media Server"]
---


```sh
#git clone https://github.com/JAlcocerT/Home-Lab
#cd ~/Home-Lab/jellyfin
#sudo docker compose up -d

##cd ~/Home-Lab
#git pull
#sudo docker compose -f ./z-homelab-setup/evolution/2601_docker-compose.yml up -d jellyfin

docker ps -a | grep -i jellyfin
#udo docker stats jellyfin #~135mb idle
```


If you see very high CPU consumption (300%+), it is likely because of **Subtitles Burn-in** or **Transcoding**.

### Quick Fix (Disable Subtitles)

*   Click your **User Icon** (top right) > **Settings**.
*   Go to **Subtitles**.
*   Set **Subtitle playback mode** to **None**.
*   Click **Save**.

---

### Permanent Fix: Hardware Acceleration (AMD 5600G)

To keep subtitles ON without crashing the CPU, enable VA-API hardware acceleration.

#### 1. Docker Compose

Add the `/dev/dri` device to your service:

```yaml
  jellyfin:
    devices:
      - /dev/dri:/dev/dri # Hardware Acceleration for AMD 5600G
```

#### 2. Jellyfin Dashboard Settings
Go to **Dashboard > Playback** and set:
*   **Hardware acceleration**: `Video Acceleration API (VAAPI)`
*   **VA-API Device**: `/dev/dri/renderD128`
*   **Hardware decoding**: Enable H.264, HEVC, VC1, VP9.
*   **Hardware encoding**: Enabled.
```