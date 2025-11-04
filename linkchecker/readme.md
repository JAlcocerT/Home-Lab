---
source_code: https://github.com/linkchecker/linkchecker
tags: "web"
---


```sh
# docker run --rm -it -u $(id -u):$(id -g) ghcr.io/linkchecker/linkchecker:latest --verbose https://https://www.psikolognevinkeskin.com/

podman run --rm -it ghcr.io/linkchecker/linkchecker:latest --verbose https://www.psikolognevinkeskin.com/ > linkchecker_psyc.txt
```

> You can use Linkchecker inside your Github Actions CI/CD workflows!

# LinkChecker - Website Link Validator

[LinkChecker](https://wummel.github.io/linkchecker/) is a free, open-source tool to check HTML documents for broken links.

## Features
- Recursive and multi-threaded checking
- Output in various formats (text, HTML, SQL, CSV, XML, etc.)
- Support for different URL types (HTTP(S), FTP, mailto:, etc.)
- Authentication support
- URL rewriting and filtering
- Sitemap support

## Prerequisites
- Docker
- Docker Compose

## Quick Start

1. **Create the reports directory**:
   ```bash
   mkdir -p /home/jalcocert/Desktop/IT/Home-Lab/linkchecker/reports
   ```

2. **Run a basic link check**:
   ```bash
   cd /home/jalcocert/Desktop/IT/Home-Lab/linkchecker
   docker-compose run --rm linkchecker https://example.com
   ```

3. **Save the output to a file**:
   ```bash
   docker-compose run --rm linkchecker --verbose https://example.com > reports/example_report.txt
   ```

## Usage Examples

### Basic Usage
```bash
docker-compose run --rm linkchecker https://example.com
```

### Check with Verbose Output
```bash
docker-compose run --rm linkchecker --verbose https://example.com > reports/verbose_report.txt
```

### Check with Specific Output Format
```bash
docker-compose run --rm linkchecker --output=html https://example.com > reports/report.html
```

### Check with Authentication
```bash
docker-compose run --rm linkchecker --user=username --password=secret https://example.com/private
```

### Check with Recursion (Follow Links)
```bash
docker-compose run --rm linkchecker --recursion-level=2 https://example.com
```

### Check a Local File
```bash
docker-compose run --rm -v $(pwd):/check linkchecker file:///check/local-file.html
```

## Common Options

| Option | Description |
|--------|-------------|
| `--verbose` | Show detailed output |
| `--output=TYPE` | Set output format (text, html, sql, csv, xml, gml, dot, etc.) |
| `--file-output=TYPE[:ENCODING][:FILENAME]` | Write output to a file |
| `--recursion-level=N` | Maximum recursion level (default: 1) |
| `--threads=N` | Number of threads to use (default: 10) |
| `--timeout=N` | Timeout in seconds for connection (default: 60) |
| `--user=USER[:PASSWORD]` | Set username and password for authentication |
| `--ignore-url=REGEX` | Regular expression of URLs to ignore |

## Configuration

### Volumes
- `./reports` - Directory where reports will be saved

### Custom Configuration
Create a `linkcheckerrc` file in the project directory and mount it to `/etc/linkchecker/linkcheckerrc` in the container.

## Running in Batch Mode

You can create a shell script to check multiple sites:

```bash
#!/bin/bash

SITES=(
  "https://example1.com"
  "https://example2.com"
  "https://example3.com"
)

for SITE in "${SITES[@]}"; do
  FILENAME="reports/$(echo $SITE | sed 's/[^a-zA-Z0-9]/_/g').txt"
  echo "Checking $SITE -> $FILENAME"
  docker-compose run --rm linkchecker --verbose "$SITE" > "$FILENAME"
done
```

## Integration

### With Cron
To schedule regular checks:

```bash
# Edit crontab
crontab -e

# Add this line to run every day at 3 AM
0 3 * * * cd /home/jalcocert/Desktop/IT/Home-Lab/linkchecker && ./check_sites.sh
```

## Troubleshooting

### Common Issues

#### Permission Issues
If you encounter permission issues with the reports directory:
```bash
chmod -R 777 reports/
```

#### Timeout Issues
Increase the timeout for slow websites:
```bash
docker-compose run --rm linkchecker --timeout=120 https://example.com
```

## License
LinkChecker is open source and licensed under the [GPL-2.0 License](https://github.com/linkchecker/linkchecker/blob/master/COPYING).

## References
- [GitHub Repository](https://github.com/linkchecker/linkchecker)
- [Official Documentation](https://wummel.github.io/linkchecker/)
- [Docker Hub](https://hub.docker.com/r/linkchecker/linkchecker)
