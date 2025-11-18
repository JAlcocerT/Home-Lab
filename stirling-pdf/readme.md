---
source_code: https://github.com/stirlingpdf/stirling-pdf
tags: ["PDF", "Document Processing"]
post: https://fossengineer.com/selfhosting-stirling-pdf/
---

# Stirling PDF

Stirling PDF is a powerful, locally hosted web-based PDF manipulation tool that allows you to perform various operations on PDF files.

## Quick Start

1. Create the necessary directories for persistent storage:

```bash
mkdir -p StirlingPDF/{trainingData,extraConfigs,customFiles,logs,pipeline}
```

2. Create the `docker-compose.yml` file


3. Start the service:

```bash
docker-compose up -d
```

## Access

Access the Stirling PDF web interface at: `http://your-server-ip:8050`

## Features

- PDF manipulation tools (merge, split, rotate, etc.)
- OCR (Optical Character Recognition) support
- Document conversion
- Form filling
- Digital signatures
- And many more PDF-related features

## Security Notes

- The default configuration has security disabled (`DOCKER_ENABLE_SECURITY=false`). For production use, enable security and set up proper authentication.
- The service runs with the default language set to British English (`en_GB`). You can modify this in the environment variables.

## Volumes

- `./StirlingPDF/trainingData`: Contains Tesseract OCR training data
- `./StirlingPDF/extraConfigs`: Additional configuration files
- `./StirlingPDF/customFiles`: Custom files and templates
- `./StirlingPDF/logs`: Application logs
- `./StirlingPDF/pipeline`: For processing pipeline files

## Updating

To update to the latest version:
```bash
docker-compose pull
docker-compose up -d --force-recreate
```

## Notes

- For additional OCR languages, download the appropriate Tesseract language files to the `trainingData` directory
- Consider enabling security and setting up authentication for production use