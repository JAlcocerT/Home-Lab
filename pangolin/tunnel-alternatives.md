# Tunnel & Remote-Access Alternatives

Notes on when public IP + port forwarding is actually required, and what to use when it isn't. Companion to `pi4-guide.md` and `pi4-newt-vps-cloudflare.md`.

## Core principle

Public IP + port forward = required **only when the home node is itself the public endpoint**.

Anything where the home node **dials outbound** to an intermediary (a VPS you own, or a third-party relay) avoids both. The intermediary holds the public IP; the home node stays invisible.

CGNAT, dynamic home IP, double-NAT all become irrelevant in the outbound-only model.

---

## Category A — Outbound-only tunnel (no port forward, no public home IP)

Home node initiates the connection. Public endpoint sits elsewhere.

| Tool | Public endpoint owner | Self-host? | Auth / UI | Notes |
|------|----------------------|------------|-----------|-------|
| **Pangolin + Newt** | You (VPS) | Yes | Built-in (SSO / password / PIN / OTP) | Self-hosted Cloudflare-Tunnel-equivalent with a real dashboard. |
| **Cloudflare Tunnel** (`cloudflared`) | Cloudflare | No | Cloudflare Access (free tier) | Easiest to set up. Closed-source data plane. HTTP-focused. |
| **Tailscale + Funnel** | Tailscale (DERP relays) | No | Tailscale ACLs / identity | Funnel exposes a tailnet service to the public internet. Free for personal use. |
| **Headscale + tailscaled** | You (VPS for control plane) | Yes | Tailscale ACLs | Self-hosted Tailscale control plane. Mesh, not gateway. |
| **Netbird** | You or hosted | Yes | OIDC | Tailscale-like with a cleaner self-host story. |
| **ZeroTier** | ZeroTier (or self-host moon) | Partial | Network controller | Older, stable, predates WireGuard. |
| **frp** | You (VPS) | Yes | Tokens | Lightweight TCP / UDP / HTTP reverse tunnel. No UI. |
| **rathole** | You (VPS) | Yes | Tokens | Faster Rust frp. Bare. |
| **chisel** | You (VPS) | Yes | None | TCP-over-HTTP, single Go binary. |
| **bore** (`ekzhang/bore`) | You or `bore.pub` | Yes | None | Tiny TCP relay. |
| **sish** | You (VPS) | Yes | SSH keys | SSH-based public tunnels (`ssh -R` to your VPS). |
| **zrok / ngrok self-hosted** | You (VPS) | Partial | Built-in | Zrok = open-source ngrok-ish. |
| **Twingate** | Twingate | No | OIDC | ZTNA, free tier. |
| **localtunnel / serveo / Pinggy** | Third party | Mostly no | Minimal | Quick demos, not production. |

---

## Category B — Direct exposure (needs port forward + public IP)

Traditional self-hosting on the home box. Home node IS the public endpoint.

- **WireGuard server at home** — UDP 51820 forwarded, reachable WAN IP required.
- **Caddy / Traefik / Nginx Proxy Manager at home** — TCP 80 / 443 forwarded.
- **OpenVPN at home** — UDP 1194 forwarded.
- **Tailscale subnet router at home with Funnel disabled** — no port forward needed, but only tailnet members can reach it (effectively Category A for the tailnet, just not public).

If you have CGNAT or a dynamic IP, Category B is unworkable. Use Category A.

---

## On WireGuard as a home server specifically

Vanilla WireGuard at home **does require port forwarding plus a reachable public IP**. WireGuard has:

- No relay protocol.
- No NAT punch on its own.
- No rendezvous / discovery server.

It's pure UDP. If the router doesn't accept inbound UDP 51820, no client connects.

Workarounds keep the WireGuard wire format but add a relay or control plane on top:

| Setup | Port forward at home? | Public IP at home? | How it works |
|-------|----------------------|--------------------|--------------|
| **Tailscale** (uses WG under the hood) | No | No | DERP relays + STUN NAT punch. |
| **Headscale + tailscaled** | No (home) | No (home; yes on Headscale VPS) | Same as Tailscale, self-hosted control plane. |
| **Netbird** (uses WG) | No | No | TURN-style relays. |
| **WG-Easy / wg-quick vanilla** | **Yes** | **Yes** | No relay layer at all. |
| **WG server on VPS, Pi peers out as client, services exposed via VPS** | No (home) | No (home) | Reverse-tunnel style. Works but no auth / UI / multi-tenant resource model — you wire Traefik or iptables yourself. |

The last row is the "poor man's Pangolin." It works for a single power user; it falls apart fast once you want multiple sites or per-resource auth.

---

## Picking by goal

| Goal | Best pick |
|------|-----------|
| Public web services, no port forward, self-hosted, with auth UI | **Pangolin + Newt** |
| Public web services, no port forward, zero-effort | **Cloudflare Tunnel** |
| Just *you* reaching home from anywhere (not public) | **Tailscale** (free) or **Headscale** (self-host) |
| Lightweight TCP forward only, no UI | **rathole** or **frp** |
| Mesh network across many home / work nodes | **Tailscale**, **Netbird**, or **Headscale** |
| Raw WireGuard, accept port forward | **wg-easy** container |

---

## Decision shortcut

```
Need to expose services to the public internet?
├── Yes
│   ├── Have public IP + can port-forward?
│   │   ├── Yes  → any reverse proxy at home (Caddy / Traefik / NPM) is fine
│   │   └── No   → outbound-only tunnel:
│   │              ├── self-hosted, with dashboard / auth → Pangolin + Newt
│   │              ├── self-hosted, minimal              → frp / rathole / chisel
│   │              └── hosted, fastest setup             → Cloudflare Tunnel
└── No, just personal remote access
    └── Tailscale (hosted) or Headscale (self-host) or Netbird
```

---

## Bottom line

- Public IP + port forward is **only** required when home is the public endpoint.
- Outbound-only tunnels (Pangolin, Cloudflare Tunnel, Tailscale Funnel, frp, rathole, chisel, sish, …) all bypass that requirement by putting the public endpoint on a VPS or third-party relay.
- Pangolin is one of many. Right pick depends on: public services vs. private mesh vs. just VPN, and self-hosted vs. hosted.
- Vanilla WireGuard at home **always** needs port forward + reachable public IP. Tailscale / Headscale / Netbird remove that requirement by adding a relay layer on top of WireGuard.
