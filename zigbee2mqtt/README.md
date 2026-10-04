# Zigbee2MQTT

Minimal Zigbee2MQTT + Mosquitto stack.

Find your coordinator:

```bash
ls -l /dev/serial/by-id
```

Create `.env` from `.env.sample`, set `ZIGBEE_ADAPTER`, then start:

```bash
docker compose up -d
```

The Zigbee2MQTT frontend is published on port `8080` by default. Keep using
the `/dev/serial/by-id/...` adapter path so USB reordering does not move the
coordinator to a different `ttyACM*` or `ttyUSB*` path after reboot.
