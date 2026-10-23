# DNS on Omarchy

## Current setup

This PC uses NetworkManager with `systemd-resolved`.

- Active connection: `Piszymsiu`
- Wi-Fi interface: `wlp0s20f3`
- LAN address: `192.168.1.15`
- Technitium DNS: `192.168.1.15`
- Quad9 fallback: `9.9.9.9`
- NetworkManager ignores the DNS server supplied by the router.
- `/etc/resolv.conf` points to the local `systemd-resolved` stub at `127.0.0.53`.
- Technitium's web console is available locally at `http://127.0.0.1:5380`.

The DNS order is configured on the NetworkManager connection. A lower DNS
priority value is preferred, so this connection uses priority `-50`.

`systemd-resolved` may retry or select another configured server when a server
is unavailable. The configured order is Technitium first, then Quad9.

## Check the current DNS configuration

Show active NetworkManager connections:

```bash
nmcli -t -f NAME,UUID,TYPE,DEVICE connection show --active
```

Show the DNS settings stored on the Wi-Fi connection:

```bash
nmcli -f connection.id,ipv4.dns,ipv4.ignore-auto-dns,ipv4.dns-priority \
  connection show 'Piszymsiu'
```

Show the DNS servers currently used by `systemd-resolved`:

```bash
resolvectl dns
resolvectl status
```

Check how `/etc/resolv.conf` is connected:

```bash
readlink -f /etc/resolv.conf
cat /etc/resolv.conf
```

The expected resolver file is `/run/systemd/resolve/stub-resolv.conf`, with
`nameserver 127.0.0.53`.

Test a normal local DNS lookup:

```bash
resolvectl query example.com
```

If `dig` is installed, test Technitium and Quad9 directly:

```bash
dig @192.168.1.15 example.com
dig @9.9.9.9 example.com
```

## Apply the current configuration

The active connection name can be confirmed with the command above. For this
PC, the applied configuration is:

```bash
nmcli connection modify 'Piszymsiu' \
  ipv4.dns '192.168.1.15,9.9.9.9' \
  ipv4.ignore-auto-dns yes \
  ipv4.dns-priority -50

nmcli connection up 'Piszymsiu'
```

This does not edit `/etc/resolv.conf` directly. NetworkManager updates
`systemd-resolved` through its normal integration.

## If the Wi-Fi connection name changes

Replace `Piszymsiu` in the commands with the active connection name shown by:

```bash
nmcli -t -f NAME,TYPE,DEVICE connection show --active
```

If the LAN address changes, update the Technitium Compose binding and the DNS
setting together. The Compose file currently uses `192.168.1.15:53` for DNS.

## Restore router-provided DNS

To stop overriding the router's DNS settings:

```bash
nmcli connection modify 'Piszymsiu' \
  ipv4.ignore-auto-dns no \
  ipv4.dns '' \
  ipv4.dns-priority 0

nmcli connection up 'Piszymsiu'
```

