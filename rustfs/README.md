# RustFS

Copy `.env.sample` to `.env`, replace the admin access key and secret key, then start:

```bash
docker compose up -d
```

Endpoints:

- S3 API: `http://SERVER_IP:9000`
- Console: `http://SERVER_IP:9001/rustfs/console/`
- API health: `http://SERVER_IP:9000/health`
- Console health: `http://SERVER_IP:9001/rustfs/console/health`

`RUSTFS_UNSAFE_BYPASS_DISK_CHECK=true` is included for single-machine homelab testing with Docker named volumes. Do not treat that layout as multi-disk durability.
