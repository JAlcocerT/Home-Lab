---
tags: ["Media Server","Music Server"]
source_code: https://github.com/jeffvli/feishin
---


Feishin is a modern, open-source, self-hosted music player that is a complete rewrite of Sonixd.

It supports playback from Subsonic-compatible music servers such as Navidrome, Jellyfin, Airsonic, Ampache, Gonic, Funkwhale, and more.[1]

### Key Features

- MPV and web player backends for audio playback.[1]
- Smart playlist editor (particularly for Navidrome users).[1]
- Synchronized and unsynchronized lyrics support.[1]
- Scrobbling playback to supported servers.[1]
- Modern UI with theme support and lyrics fetching.[1]

Installation & Usage

- **Desktop App:** Downloadable for all major platforms, recommended for full functionality including both player backends and built-in lyrics fetching.[1]
- **Web App:** Available at feishin.vercel.app, limited to web backend.[1]
- **Docker:** Can be run with the official image or Docker Compose, supporting environment variables for server configuration and user management.[1]


### Supported Servers

- Navidrome
- Jellyfin
- Airsonic-Advanced
- Ampache
- Funkwhale
- Gonic
- LMS
- Nextcloud Music
- Supysonic
- And others supporting Subsonic API.[1]

### Configuration Details

- On startup, MPV binary path is required if using the MPV backend.[1]
- Server management is via the UI, supporting multiple servers and user authentication.[1]
- Optional environment variables allow locking specific server configuration for deployments.[1]

### Development

- Built with Electron, TypeScript, and React.[1]
- Can be developed locally using Node.js and pnpm workflows.[1]

### Project Details

- License: GPL-3.0.[1]
- Over 5,000 GitHub stars and 207 forks as of late 2025.[1]
- Actively maintained with regular releases and a growing contributor base.[1]

Feishin offers a robust, modern alternative for users looking to self-host a Subsonic-compatible music player with both desktop and web deployment options.[1]

[1](https://github.com/jeffvli/feishin)