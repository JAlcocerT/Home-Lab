# EdgeEver

EdgeEver is an Evernote-style knowledge base with a Docker self-hosted mode.

## Start

```bash
cp .env.sample .env
nano .env
docker compose up -d
```

Then open:

```text
http://192.168.1.2:8787/
```

or, from the host:

```bash
curl http://127.0.0.1:8787/api/health
```

## Notes

- The default username in this compose is `admin`.
- Set the password in `.env` before starting.
- Data is stored in the `edgeever-data` Docker volume under `/data` inside the container.
- Docker mode uses SQLite plus local filesystem resources by default.
- Back up the complete `/data` volume before upgrading.
