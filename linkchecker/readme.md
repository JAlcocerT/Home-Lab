---
source_code: https://github.com/linkchecker/linkchecker
post: https://fossengineer.com/linkchecker-broken-link-checker/
tags: ["web", "seo", "link-checking", "cli", "docker"]
---

# LinkChecker

LinkChecker is a Python CLI that checks links in HTML documents, local static-site output, or full websites.

It is not a long-running web service. Use the Compose file as a repeatable one-shot runner:

```bash
mkdir -p reports
docker compose run --rm linkchecker --version
```

Check a public site:

```bash
docker compose run --rm linkchecker --verbose https://example.com
```

Write an HTML report:

```bash
docker compose run --rm linkchecker \
  --no-status \
  --output=none \
  --file-output=html/utf-8/reports/example.html \
  https://example.com
```

Check a local static build:

```bash
docker compose run --rm linkchecker --verbose ./public/index.html
```

Useful options:

| Option | Purpose |
| --- | --- |
| `--recursion-level=2` | Limit crawl depth. Use this before pointing it at large sites. |
| `--check-extern` | Check external links too. |
| `--ignore-url=REGEX` | Ignore URLs matching a Python regular expression. |
| `--no-follow-url=REGEX` | Check matching URLs but do not recurse into them. |
| `--threads=5` | Limit concurrency. |
| `--timeout=30` | Lower the default timeout for slow links. |
| `--output=none` | Suppress console result output when using file outputs. |
| `--file-output=html/utf-8/reports/report.html` | Write a persistent report file. |

The compose file pins `ghcr.io/linkchecker/linkchecker:10.6.0`. Upstream also publishes a rolling `latest` image, but pinned tags are more reproducible for public snippets.

Do not put credentials directly in this repository. If you need authenticated checks, pass them interactively or through a private local wrapper that is not committed.
