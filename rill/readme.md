---
source_code: https://github.com/rilldata/rill
tags: ["Gen-BI"]
---

```sh
git clone https://github.com/rilldata/rill
#curl https://rill.sh

# Increase Node.js memory to 4GB
export NODE_OPTIONS="--max-old-space-size=4096"

# Retry the build
make

# Run
#./rill start my-project

docker build -t rill:latest .

#docker volume create rill-project

docker run -it --rm \
  -p 9009:9009 \
  -v rill-project:/app/project \
  --user root \
  rill:latest start /app/project
```