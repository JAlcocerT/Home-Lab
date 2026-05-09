Initially I had [this script](https://github.com/JAlcocerT/Linux/blob/main/Z_Linux_Installations_101/Selfhosting_101.sh), then, this one for the [Pi for the cam setup](https://github.com/JAlcocerT/RPi/blob/main/Z_RPi_Cam/homelab-selfhosting.sh) and for [general setup](https://github.com/JAlcocerT/RPi/blob/main/Z_SelfHosting/homelab-selfhosting.sh).

It has been improved: *for just homelab, or for quick desktop setup*

```sh
make help
chmod +x homelab-selfhosting.sh
./homelab-selfhosting.sh
#sudo ./z-desktop-x-homelab/Linux_Setup_101.sh
```

> See under `./evolution` the stacks I've been using to selfhost across the years.

```sh
#docker system df
docker system prune -a --volumes
```
