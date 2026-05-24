# `tshark` Cheat Sheet

This file collects the most common `tshark` commands for packet capture and inspection.

## Notes

- These commands assume `tshark` is installed and available in `PATH`.
- In this environment, `tshark` is not installed and Docker/Podman are not available, so I could not execute the commands and capture live output here.
- Replace `eth0` with your actual interface name.

## Install

### Debian / Ubuntu

```sh
sudo apt update
sudo apt install tshark
```

If the installer asks whether non-superusers should be able to capture packets, choosing `Yes` is the usual option for a workstation or homelab box where you want to run captures without always using `sudo`. 

Wireshark documents that capture privileges can also be managed with Linux capabilities, and that non-root capture requires sufficient permissions. citeturn0search7turn0search14

### Verify the install

```sh
tshark -v
```

Expected output:

```text
TShark (Wireshark) 4.x.x ...
```

### If capture fails without sudo

If `tshark -D` or live capture fails as a regular user, run it with `sudo` or adjust capture permissions on the host so your user can read packet capture interfaces. Wireshark’s documentation notes that capture requires sufficient privileges. citeturn0search7turn0search14

## 1. List capture interfaces

```sh
tshark -D
```

Expected output:

```text
1. eth0
2. lo
3. docker0
...
```

## 2. Capture packets on an interface

```sh
tshark -i eth0
#tshark -i wlp3s0
```

Expected output:

```text
Capturing on 'eth0'
 ** (tshark:12345) 10:15:00.000000 [Main MESSAGE] -- Capture started.
 1 0.000000 192.168.1.10 -> 192.168.1.1  DNS  ...
 2 0.001234 192.168.1.10 -> 142.250.x.x TCP  ...
```

## 3. Capture with a capture filter

```sh
tshark -i eth0 -f "tcp port 443"
#tshark -i wlp3s0 -f "tcp port 443"
```

Expected output:

```text
Capturing on 'eth0'
 1 0.000000 192.168.1.10 -> 172.217.x.x TCP 443 ...
```

## 4. Read a saved capture file

```sh
tshark -r capture.pcapng
```

Expected output:

```text
 1 0.000000 192.168.1.10 -> 192.168.1.1 DNS  Standard query 0x1234 A example.com
 2 0.001234 192.168.1.1 -> 192.168.1.10 DNS  Standard query response 0x1234 A 93.184.216.34
```

## 5. Show only a display filter

```sh
tshark -r capture.pcapng -Y "dns"
```

Expected output:

```text
 1 0.000000 192.168.1.10 -> 192.168.1.1 DNS  Standard query 0x1234 A example.com
 2 0.001234 192.168.1.1 -> 192.168.1.10 DNS  Standard query response 0x1234 A 93.184.216.34
```

## 6. Display selected fields

```sh
tshark -r capture.pcapng -T fields -e frame.number -e ip.src -e ip.dst -e tcp.port
```

Expected output:

```text
1	192.168.1.10	192.168.1.1	443
2	192.168.1.1	192.168.1.10	443
```

## 7. Follow a TCP conversation

```sh
tshark -r capture.pcapng -q -z follow,tcp,ascii,0
```

Expected output:

```text
===================================================================
Follow: tcp,ascii
Filter: tcp.stream eq 0
===================================================================
GET / HTTP/1.1
Host: example.com

HTTP/1.1 200 OK
Content-Type: text/html
```

## 8. Save a capture to a file

```sh
tshark -i eth0 -w capture.pcapng
```

Expected output:

```text
Capturing on 'eth0'
File: capture.pcapng
```

## 9. Print protocol hierarchy statistics

```sh
tshark -r capture.pcapng -q -z io,phs
```

Expected output:

```text
===================================================================
Protocol Hierarchy Statistics
Filter: 
...
```

## 10. Quick DNS inspection

```sh
tshark -i eth0 -f "udp port 53"
```

Expected output:

```text
Capturing on 'eth0'
 1 0.000000 192.168.1.10 -> 192.168.1.1 DNS  Standard query 0x1234 A example.com
```

## Common display filters

- `dns`
- `http`
- `tls`
- `tcp.port == 443`
- `ip.addr == 192.168.1.50`
- `frame contains "password"`

## Common capture filters

- `tcp port 443`
- `udp port 53`
- `host 192.168.1.50`
- `net 192.168.1.0/24`
