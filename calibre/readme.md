---
tags: ["ebooks","Documents"]
source_code: https://github.com/Calibre-Web/Calibre-Web
---


You can use calibre to create [your own epub from html](https://github.com/JAlcocerT/ebook-ideas/tree/master/x-html-to-epub):

```sh
docker run --rm -v "$PWD/x-rmd":/work ghcr.io/linuxserver/calibre:latest \
  bash -lc 'ebook-convert /work/book.html /work/cover-only.epub --cover=/work/cover.png --title="Sell Your Ebook" --authors="Your Name"'
```