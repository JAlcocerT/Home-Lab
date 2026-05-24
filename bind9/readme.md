---
source_code: ?ref=fossengineer.com
post: 
tags: ["DNS"]
---

# BIND9

BIND9, short for Berkeley Internet Name Domain version 9, is a DNS server
software package. DNS is the system that translates domain names, such as
`example.com`, into IP addresses that computers can connect to.

BIND9 can be used in several ways:

- As an authoritative DNS server for domains or internal zones you control.
- As a recursive DNS resolver for clients on your network.
- As a forwarding DNS server that sends DNS queries to upstream providers.
- As an internal DNS server for homelab names, local services, VMs, containers,
  and private network zones.

In a homelab, BIND9 is commonly used to create stable local DNS names such as
`nas.home`, `router.lan`, `dns.lab`, or service-specific names instead of
remembering IP addresses.

## Pros

- Full control over DNS zones, records, forwarding, recursion, access rules, and
  local naming.
- Useful for homelabs, labs, and internal networks where private DNS names are
  needed.
- Can act as an authoritative DNS server, not just a DNS forwarder.
- Can run as a recursive resolver for local clients.
- Supports split-horizon DNS, where internal and external clients can receive
  different DNS answers.
- Mature, widely used, and heavily documented.
- Supports advanced DNS features such as DNSSEC, TSIG, zone transfers, dynamic
  updates, IPv6, and views.
- Good learning tool if you want to understand how DNS works in detail.

## Cons

- More complex to configure than simpler tools such as Pi-hole, AdGuard Home,
  dnsmasq, or Unbound.
- Small configuration mistakes can break DNS resolution for the network.
- Misconfiguration can create security risks, such as open recursion or exposed
  zone transfers.
- Requires ongoing maintenance, including updates, log review, record cleanup,
  and backups of zone files.
- Can be overkill if you only need a few local hostnames or basic DNS forwarding.
- DNS troubleshooting can be confusing because of caching, TTLs, forwarders,
  recursion, and authoritative responses.
- Static records can become stale unless they are managed manually or integrated
  with DHCP/automation.
- Running public authoritative DNS yourself requires extra care for redundancy,
  firewalling, uptime, glue records, monitoring, and security.

## When It Makes Sense

BIND9 is a strong choice when you want detailed DNS control, internal zones,
authoritative DNS, split DNS, or a deeper understanding of DNS administration.

For a simple home network where the main goals are ad blocking and easy local
names, Pi-hole or AdGuard Home may be easier. For a lightweight resolver,
Unbound or dnsmasq may also be simpler.

## Using BIND9 with Pi-hole

Some homelabs use Pi-hole and BIND9 together. This lets Pi-hole handle the
user-friendly filtering features while BIND9 handles the more advanced DNS
server features.

A common setup is:

```text
Devices -> Pi-hole -> BIND9 -> upstream DNS / root DNS
```

In this setup, Pi-hole usually provides:

- Ad and tracker blocking.
- DNS query logs.
- Per-client visibility.
- A web UI.
- Blocklists and allowlists.

BIND9 usually provides:

- Local authoritative zones, such as `home.lab` or `lan.example`.
- Custom records for servers, VMs, containers, and services.
- Recursive DNS resolution.
- Forwarding rules.
- Split DNS, if needed.

Another possible setup is:

```text
Devices -> Pi-hole
             |
             +-> BIND9 for local zones
             +-> public DNS for everything else
```

This is useful when Pi-hole should answer client DNS queries, but only send
specific internal domains to BIND9.

## Router and DHCP DNS

To make all devices use Pi-hole and BIND9, the router or DHCP server should
usually hand out Pi-hole as the DNS server:

```text
Devices -> Pi-hole -> BIND9 -> upstream DNS / root DNS
```

This gives devices the benefits of Pi-hole filtering and logging while still
allowing BIND9 to provide local zones, custom records, recursion, or forwarding.

If the router gives clients BIND9 directly as their DNS server, clients will
usually bypass Pi-hole. DNS will still work, but Pi-hole ad blocking and logging
will not apply to those clients.

## Failure and Redundancy

If the only DNS server on the network goes down, the internet will look broken
for most devices. Existing connections may continue working for a while, but new
website and app lookups will fail because domain names cannot be resolved.

The best option is to run two DNS filtering servers:

```text
Primary DNS:   Pi-hole 1
Secondary DNS: Pi-hole 2
```

Both Pi-hole instances can forward to BIND9:

```text
Devices -> Pi-hole 1 -> BIND9
        -> Pi-hole 2 -> BIND9
```

This keeps ad blocking and local DNS behavior working even if one Pi-hole server
is offline.

A simpler fallback setup is:

```text
Primary DNS:   Pi-hole
Secondary DNS: router, Cloudflare, Quad9, or another public resolver
```

This keeps internet access working if Pi-hole goes down, but it can make ad
blocking and DNS logging inconsistent. Some devices may use the secondary DNS
server even when Pi-hole is healthy.

Recommended homelab design:

```text
Devices -> Pi-hole 1
        -> Pi-hole 2

Pi-hole 1 -> BIND9
Pi-hole 2 -> BIND9

BIND9 -> upstream DNS / root DNS
```

Run the second Pi-hole on a different device, VM, LXC container, NAS, or other
reliable host. Avoid putting every DNS role on one machine if internet access is
important for the whole network.
