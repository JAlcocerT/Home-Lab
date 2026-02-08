Initially I had [this script](https://github.com/JAlcocerT/Linux/blob/main/Z_Linux_Installations_101/Selfhosting_101.sh)

It has been improved: *for just homelab, or for quick desktop setup*

```sh
chmod +x homelab-selfhosting.sh
./homelab-selfhosting.sh
#sudo ./z-desktop-x-homelab/Linux_Setup_101.sh
```

> See under `./evolution` the stacks I've been using to selfhost across the years.

```sh
#docker system df
docker system prune -a --volumes
```