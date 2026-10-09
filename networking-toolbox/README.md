---
source_code: https://github.com/lissy93/networking-toolbox
post: https://fossengineer.com/selfhosting-networking-toolbox/
tags: ["networking", "tools", "self-hosting"]
---

# Networking Toolbox

Networking Toolbox is an offline-first web toolbox for subnetting, CIDR, IP conversion, DNS, DHCP, diagnostics, and networking reference material.

Start it:

```bash
docker compose up -d
```

Open:

```text
http://localhost:6162
```

The compose maps `${NETWORKING_TOOLBOX_PORT:-6162}` on the host to port `3000` in the container.

The container is also hardened with `no-new-privileges`, `cap_drop: ALL`, a read-only root filesystem, and `/tmp` mounted as tmpfs.

Copy `.env.sample` to `.env` if you want to change branding, theme, layout, analytics behavior, or DNS diagnostic safety settings:

```bash
cp .env.sample .env
```

Useful endpoints:

```bash
curl -fsS http://127.0.0.1:6162/health
curl -fsS http://127.0.0.1:6162/version
curl -fsS http://127.0.0.1:6162/api
```

The public JSON API calculation endpoints use `POST`. Example:

```bash
curl -fsS -X POST http://127.0.0.1:6162/api/subnetting/ipv4-subnet-calculator \
  -H 'content-type: application/json' \
  --data '{"cidr":"192.168.10.0/24"}'
```

Other useful homelab API endpoints include:

```bash
curl -fsS -X POST http://127.0.0.1:6162/api/cidr/summarize \
  -H 'content-type: application/json' \
  --data '{"input":"192.168.1.0/25\n192.168.1.128/25","mode":"optimize"}'

curl -fsS -X POST http://127.0.0.1:6162/api/dns/validate-a-record \
  -H 'content-type: application/json' \
  --data '{"name":"nas.home.arpa","value":"192.168.1.10","ttl":3600}'
```

Keep `NTB_ALLOW_CUSTOM_DNS=false` and `NTB_BLOCK_PRIVATE_DNS_IPS=true` unless you specifically need user-supplied DNS resolvers. Those defaults reduce SSRF risk in diagnostic tools.
