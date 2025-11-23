---
source_code: https://github.com/yamlresume/yamlresume
tags: ["Career","Curriculum","CV","Resume","Job"]
official_docs: https://yamlresume.dev/docs/layout/templates
---

```sh
docker run --rm -v $(pwd):/home/yamlresume yamlresume/yamlresume new my-resume.yml #new
docker run --rm -v $(pwd):/home/yamlresume yamlresume/yamlresume build my-resume.yml #build to pdf
```