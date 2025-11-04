---
source_code: https://github.com/getumbrel/umbrel
post: 
tags: ["OS","PaaS","OS inside container"]
---


Thanks to https://github.com/dockur/umbrel we can have all these apps https://apps.umbrel.com/category/all but via container, instead of a full OS installation.

```sh
#docker run -it --rm --name umbrel --pid=host -p 80:80 -v "${PWD:-.}/umbrel:/data" -v "/var/run/docker.sock:/var/run/docker.sock" --stop-timeout 60 docker.io/dockurr/umbrel
```

> MIT | umbrelOS inside a Docker container.


```sh
#df -h | egrep '^Filesystem|^/dev/sda2|^/dev/nvme|^/dev/sdb1'
mkdir /mnt/data1tb
#lsblk
sudo mount /dev/sdb1 /mnt/data1tb #one time mount only
df -h | grep data1tb
#sudo docker compose up -d #review the data path!!!
#sudo docker logs umbrel
#sudo docker stats umbrel
```

> Go to `http://192.168.1.2:86/onboarding` and later to `http://192.168.1.2:86/app-store/category/all`

---

Yes, absolutely! Umbrel is part of a growing category of **turnkey self-hosting platforms** that aim to make running multiple web applications via **Docker containers** easy for non-technical users. They often provide an OS or a simple installation script, a clean web UI, and an "App Store" for one-click deployment.

Here are the top alternatives to Umbrel that function in a similar way:

## 🏡 Top Umbrel Alternatives

| Platform | Primary Focus | Key Features |
| :--- | :--- | :--- |
| **CasaOS** | **Simplicity & Home Cloud** | Extremely user-friendly interface. Focuses heavily on personal file management (like a local Dropbox/Google Drive). Great for Raspberry Pi, NUCs, and old PCs. |
| **YunoHost** | **Digital Independence** | Long-running, Debian-based platform. Strong focus on privacy, decentralization, and ease of maintenance/upgrades. Offers a wide range of apps for communication, hosting, and productivity. |
| **StartOS (by Start9)** | **Sovereignty & Privacy** | More focused on the "sovereign computing" and decentralized web. It is a full Linux distribution. Known for running services like Bitcoin/Lightning nodes, and decentralized applications (like NOSTR relays) in an isolated, secure environment. |
| **OpenMediaVault** | **Network Attached Storage (NAS)** | While primarily a NAS solution, OMV is a powerful base that supports Docker/Portainer. It requires a bit more technical knowledge than Umbrel or CasaOS but is highly flexible and robust for storage and running containers. |
| **Portainer (or Dockge)** | **Docker Management UI** | This is not a full OS, but a Web UI for managing Docker containers. If you install a base Linux OS (like Debian) and then install Portainer, you get a powerful visual interface to deploy **any** Docker image easily, offering maximum flexibility but requiring more initial setup than the all-in-one solutions above. |

---

### What Makes These Platforms Similar to Umbrel?

1.  **Containerization (Docker):** They all use Docker or similar technology to run apps in isolated environments, making installation and uninstallation clean and simple.
2.  **App Store Model:** They feature a curated list of popular self-hosted applications (like Nextcloud, Jellyfin, Vaultwarden, etc.) that can be installed with a **single click**.
3.  **Web Interface:** They provide a simple, graphical user interface (GUI) accessible via a web browser, eliminating the need to constantly use the command line (Terminal/SSH).
4.  **Hardware Versatility:** Most support installation on a variety of hardware, including Raspberry Pi, single-board computers, and standard x86 desktops/servers.

The video below offers a comparison of three popular options in this self-hosted category, including Umbrel and CasaOS.

You might find it helpful to see a comparison of three major contenders in this space, including Umbrel, CasaOS, and OpenMediaVault, in [this cloud OS comparison](https://www.youtube.com/watch?v=eAWm4plNKgI).
http://googleusercontent.com/youtube_content/1