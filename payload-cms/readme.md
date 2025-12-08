---
source_code: https://github.com/payload-cms/payload
official_docs: https://payloadcms.com/docs
tags: ["Headless CMS","OSS for Business","Web","WYSIWYG"]
---


```sh
# Build the Docker image
docker build -t payload-cms .

# Run the PayloadCMS container 
# docker run -p 3000:3000 \
#   -e DATABASE_URI=mongodb://your-mongo-host:27017/payload?authSource=admin \
#   -e PAYLOAD_SECRET=your-secret-key \
#   payload-cms
```

> Thanks to https://sliplane.io/blog/how-to-run-payload-cms-in-docker