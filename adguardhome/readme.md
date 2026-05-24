---
tags: ["DNS"]
source_code: https://github.com/AdguardTeam/AdGuardHome
---

# AdGuard Home

AdGuard Home is a network-wide DNS filtering server. Devices on the network use
it as their DNS server, and AdGuard Home blocks unwanted domains before devices
connect to them.

It is commonly used for:

- Blocking ads, trackers, malware domains, telemetry, and unwanted services.
- Managing DNS blocklists and allowlists from a web UI.
- Seeing DNS query logs per device.
- Applying different DNS filtering rules to different clients.
- Providing simple local DNS rewrites for homelab services.
- Forwarding DNS queries to upstream resolvers such as Cloudflare, Quad9,
  Google DNS, Unbound, or BIND9.

In a homelab, AdGuard Home is often used as the DNS server given to clients by
the router or DHCP server.

```text
Devices -> AdGuard Home -> upstream DNS
```

It can also be used together with BIND9:

```text
Devices -> AdGuard Home -> BIND9 -> upstream DNS / root DNS
```

In this design, AdGuard Home provides filtering, logs, and a web UI, while BIND9
provides advanced DNS server features.

## How It Differs from BIND9

AdGuard Home and BIND9 both deal with DNS, but they are built for different
purposes.

AdGuard Home is mainly a DNS filtering and privacy tool. It is designed to be
easy to manage from a browser and is focused on blocking unwanted DNS requests.

BIND9 is a general-purpose DNS server. It is designed for authoritative DNS,
recursive DNS, custom zones, zone transfers, DNS views, and advanced DNS
administration.

## Feature Comparison

| Feature | AdGuard Home | BIND9 |
| --- | --- | --- |
| Main purpose | DNS filtering and privacy | Full DNS server |
| Web UI | Yes | No, usually config files |
| Ad/tracker blocking | Built in | Not built in |
| Query logs | Built in | Possible through logs, less friendly |
| Per-client rules | Built in | Possible, but more complex |
| Local DNS records | Basic DNS rewrites | Full zone files |
| Authoritative DNS | Limited/not the main purpose | Yes |
| Recursive DNS | Forwards to upstream resolvers | Yes |
| Split DNS | Limited/simple | Strong support with views/zones |
| DNSSEC | Can use upstream DNSSEC behavior | Strong DNSSEC support |
| Configuration style | Web UI and YAML | Text config and zone files |
| Best for beginners | Easier | Harder |
| Best for complex DNS | Limited | Strong |

## Pros of AdGuard Home

- Easier to install and manage than BIND9 for most home users.
- Provides a clean web UI.
- Blocks ads, trackers, malware domains, and unwanted services network-wide.
- Shows DNS query logs in a readable way.
- Supports per-client filtering rules.
- Good choice when the main goal is privacy, filtering, and visibility.
- Can forward local domains to another DNS server, such as BIND9.
- Can be enough by itself for simple homelab DNS needs.

## Cons of AdGuard Home

- Not a full replacement for BIND9 if you need advanced DNS administration.
- Local DNS features are simpler than BIND9 zone files.
- Not ideal for running serious authoritative DNS zones.
- Less flexible for complex split DNS designs.
- If it is the only DNS server and it goes down, devices may lose DNS
  resolution.
- Like Pi-hole, using a public secondary DNS can cause some clients to bypass
  filtering.
- Blocklists can occasionally break websites or apps until allowlisted.

## When to Use AdGuard Home

Use AdGuard Home when you want:

- Network-wide ad and tracker blocking.
- A simple web UI for DNS filtering.
- DNS logs that are easy to inspect.
- Per-device DNS rules.
- Basic local DNS names or rewrites.
- A simpler alternative to Pi-hole.

## When to Use BIND9

Use BIND9 when you want:

- Full control over DNS zones.
- Authoritative DNS for internal or external domains.
- Recursive DNS under your control.
- Advanced local DNS records.
- Split-horizon DNS.
- Zone transfers, TSIG, DNS views, and other advanced DNS features.
- A deeper understanding of how DNS works.

## Using Both Together

For many homelabs, the best design is to use AdGuard Home in front of BIND9:

```text
Devices -> AdGuard Home -> BIND9 -> upstream DNS / root DNS
```

This gives clients the benefits of AdGuard Home filtering and logging while
still allowing BIND9 to manage local zones and advanced DNS behavior.

The router or DHCP server should usually hand out AdGuard Home as the DNS
server:

```text
Primary DNS:   AdGuard Home 1
Secondary DNS: AdGuard Home 2
```

Both AdGuard Home instances can forward to BIND9:

```text
AdGuard Home 1 -> BIND9
AdGuard Home 2 -> BIND9
```

This keeps filtering active while reducing the chance that DNS breaks if one
AdGuard Home instance goes offline.

## Simple Recommendation

For a basic home network, AdGuard Home alone may be enough.

For a homelab where you want ad blocking plus proper internal DNS zones, use:

```text
Devices -> AdGuard Home -> BIND9
```

For better reliability, run two AdGuard Home instances and point both of them to
BIND9.
