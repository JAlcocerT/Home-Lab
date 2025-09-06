---
# Required
title: "Hello from Markdown with an image"

# Optional
slug: hello-from-markdown
status: published # draft | published | scheduled
excerpt: "Short summary of this post"
# Provide a LOCAL image path to upload and set as feature image
# Relative paths are resolved from this markdown file's folder
feature_image_path: ./JAlcocerTechlogo.png
feature_image_alt: "JAlcocer Tech Logo"
feature_image_caption: "Our brand logo uploaded via the Admin API SDK"
# published_at: "2025-09-06T12:00:00.000Z" # for scheduled/published

# Tags can be array or comma-separated string
# tags: news, release
# tags:
#   - news
#   - release
---

# Hello from Markdown and the Ghost Admin API SDK

This post was authored in Markdown and created via the Ghost Admin API SDK.

- Supports front matter for meta (title, tags, status)
- Converts Markdown to HTML automatically via `marked`
- If `feature_image_path` exists locally, the script will upload it and set it as the post's feature image

Feel free to edit this file and re-run the creator script.

## Sample Table

| Feature         | Supported | Notes                                      |
|-----------------|-----------|--------------------------------------------|
| Front matter    | Yes       | title, tags, status, image fields, etc.    |
| Image upload    | Yes       | Uses `feature_image_path` local file       |
| HTML rendering  | Yes       | Markdown converted to HTML via `marked`    |
| Publish status  | Yes       | Set `status: published` or `draft`         |
