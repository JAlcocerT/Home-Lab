# DNS for Homelabs

## The homelab-ideal setup: Pi-hole + Unbound

**Pi-hole** is a local DNS sinkhole that blocks ads, trackers, and malware domains across your whole network.

**Unbound** is a recursive resolver that queries root servers directly — no upstream provider ever sees your queries.

Together they give you full DNS autonomy: no third-party sees your lookups, you control the blocklists, and you get a dashboard showing every DNS query on your LAN.

---

## Pi-hole deployment modes

### Mode A — localhost only (what this script does, recommended)

Pi-hole runs on the same machine and serves DNS only for that machine.
Your router and the rest of the network never know Pi-hole exists.

```
[this machine]
  └─ system DNS → 127.0.0.1:53 (Pi-hole)
       └─ upstream → 9.9.9.9 (Quad9)
```

**If Pi-hole's container crashes**, systemd-resolved falls back to Quad9 automatically
(set via `FallbackDNS=9.9.9.9` in `/etc/systemd/resolved.conf` — done by this script).
Your machine keeps resolving. The router and LAN are completely unaffected.

**Downside:** only this server gets the ad/tracker blocking. Other devices on your network still use the router's DNS.

### Mode B — network-wide (manual, not done by this script)

Configure your router's DHCP to hand out your server's LAN IP as the DNS server.
Every device on the network then queries Pi-hole.

```
[LAN devices]
  └─ DNS → <server LAN IP>:53 (Pi-hole)
       └─ upstream → 9.9.9.9 (Quad9)
```

**The risk you identified is real:** if your server goes offline, the whole network loses DNS and effectively loses internet access. Mitigation: set a secondary DNS in your router (e.g. 9.9.9.9) so devices fall back automatically when Pi-hole is unreachable. Most routers support two DNS entries for exactly this reason.

**Recommendation:** start with Mode A. You get Pi-hole on your server with zero risk to the rest of the network. Switch to Mode B later once you're confident in the server's uptime, and always set a public DNS as the router's secondary.

Pi-hole admin UI: `http://127.0.0.1:8053/admin` (localhost only — SSH tunnel for remote: `ssh -L 8053:127.0.0.1:8053 user@host`).

---

## Public DNS fallback options

| # | Provider     | Primary         | Secondary        | Notes |
|---|--------------|-----------------|------------------|-------|
| 1 | **Quad9**    | 9.9.9.9         | 149.112.112.112  | Non-profit (CH), DNSSEC, malware blocking. Best default for privacy. |
| 2 | Cloudflare   | 1.1.1.1         | 1.0.0.1          | Fastest globally, commercial (US). No filtering by default. |
| 3 | Cloudflare+  | 1.1.1.2         | 1.0.0.2          | Same as above + malware blocking. |
| 4 | AdGuard      | 94.140.14.14    | 94.140.15.15     | Ad + tracker blocking. No account needed. |
| 5 | Mullvad      | 194.242.2.2     | 194.242.2.3      | Strict no-logging, no filtering. Good if you just want privacy. |
| 6 | ControlD     | freedns.controld.com | —           | Configurable filtering tiers (free/paid). |
| 7 | NextDNS      | varies          | —                | Dashboard + stats, free up to 300k queries/month. Closest to Pi-hole without self-hosting. |
| 8 | DNS4EU       | protective.joindns4.eu | —        | EU-based, malware + parental options. GDPR-friendly. |

**Recommendation:** Quad9 as a system default, Pi-hole if you want network-wide blocking and don't mind running one more container.

---

## Encrypted DNS (DoH / DoT / DoQ)

Plain DNS on port 53 is unencrypted — your ISP (and anyone on the path) can see every query.

DoH (DNS-over-HTTPS) and DoT (DNS-over-TLS) encrypt the traffic. 

DoQ (DNS-over-QUIC) is newer and faster.

For a homelab server, the most practical approach is to run **Pi-hole** or **AdGuard Home** as a local resolver and configure those to use DoT/DoH upstream — then your whole network gets encrypted DNS without configuring every device.

### DoH endpoints

| Provider | DoH URL |
|----------|---------|
| AdGuard | `https://dns.adguard.com/dns-query` |
| AdGuard Family | `https://dns-family.adguard.com/dns-query` |
| Cloudflare | `https://cloudflare-dns.com/dns-query` |
| Cloudflare + malware | `https://security.cloudflare-dns.com/dns-query` |
| ControlD (no filter) | `https://freedns.controld.com/p0` |
| ControlD + malware | `https://freedns.controld.com/p1` |
| ControlD + malware + ads | `https://freedns.controld.com/p2` |
| DNS4EU (malware) | `https://protective.joindns4.eu/dns-query` |
| DNS4EU (no filter) | `https://unfiltered.joindns4.eu/dns-query` |
| DNSForge | `https://dnsforge.de/dns-query` |
| Google | `https://dns.google/dns-query` |
| Mullvad (no filter) | `https://dns.mullvad.net/dns-query` |
| Mullvad + ads | `https://adblock.dns.mullvad.net/dns-query` |
| Mullvad + malware + ads | `https://base.dns.mullvad.net/dns-query` |
| OpenBLD | `https://ada.openbld.net/dns-query` |
| Quad9 | `https://dns9.quad9.net/dns-query` |
| Quad9 + ECS | `https://dns11.quad9.net/dns-query` |

### DoT hostnames

| Provider | DoT hostname |
|----------|-------------|
| AdGuard | `dns.adguard.com` |
| AdGuard Family | `family.adguard.com` |
| Cloudflare | `one.one.one.one` |
| Cloudflare + malware | `security.cloudflare-dns.com` |
| ControlD (no filter) | `p0.freedns.controld.com` |
| ControlD + malware | `p1.freedns.controld.com` |
| ControlD + malware + ads | `p2.freedns.controld.com` |
| DNS4EU (malware) | `protective.joindns4.eu` |
| DNS4EU (no filter) | `unfiltered.joindns4.eu` |
| Google | `dns.google` |
| Mullvad (no filter) | `dns.mullvad.net` |
| Mullvad + ads | `adblock.dns.mullvad.net` |
| Mullvad + malware + ads | `base.dns.mullvad.net` |
| Quad9 | `dns.quad9.net` |
| Quad9 + ECS | `dns11.quad9.net` |

### DoQ hostnames (DNS-over-QUIC)

| Provider | DoQ hostname |
|----------|-------------|
| AdGuard | `dns.adguard.com` |
| AdGuard Family | `dns-family.adguard.com` |
| ControlD (no filter) | `p0.freedns.controld.com` |
| ControlD + malware | `p1.freedns.controld.com` |
| ControlD + malware + ads | `p2.freedns.controld.com` |
| DNSForge | `dnsforge.de` |

---

## Decision guide

```
Do you want ad/tracker blocking across your whole LAN?
├── Yes → Pi-hole (+ Unbound for full recursion, or Quad9/AdGuard as upstream)
└── No  → pick a public resolver:
          Privacy-first:   Quad9 or Mullvad
          Speed-first:     Cloudflare 1.1.1.1
          Ad-blocking:     AdGuard DNS
          Configurable:    NextDNS or ControlD
          EU jurisdiction: DNS4EU
```

## Notes

- `rp_filter=1` (set by this script's sysctl hardening) can interfere with Pi-hole's routing on multi-homed systems. If Pi-hole stops resolving after sysctl hardening, check `net.ipv4.conf.all.rp_filter`.
- Pi-hole's docker.sock is not mounted; it does not need Docker socket access.
- Pi-hole admin UI in this script is bound to `127.0.0.1:8053` (localhost only). For LAN access, bind to your LAN IP instead: `-p <LAN_IP>:80:80`.
