---
source_code: https://github.com/OpenDroneMap/ODM
post: https://fossengineer.com/opendronemap-odm-drone-photogrammetry/
tags: ["maps", "drone", "photogrammetry", "geospatial", "docker"]
---

# OpenDroneMap ODM

ODM is a run-on-demand photogrammetry processor. It has no web UI in this compose.

## Folder layout

```text
datasets/
  project/
    images/
      IMG_0001.JPG
      IMG_0002.JPG
```

## CPU run

```bash
cp .env.sample .env
docker compose run --rm odm
```

Or override the project and options directly:

```bash
docker compose run --rm odm --project-path /datasets my-project --dsm --orthophoto-resolution 2
```

## GPU run

Requires the NVIDIA Container Toolkit and a working `docker run --gpus all ... nvidia-smi` check.

```bash
docker compose --profile gpu run --rm odm-gpu --project-path /datasets project --feature-type sift
```

## Outputs

The processed files appear inside the same dataset folder, typically under:

- `odm_orthophoto/odm_orthophoto.tif`
- `odm_georeferencing/odm_georeferenced_model.laz`
- `odm_texturing/odm_textured_model.obj`
- `odm_dem/`
- `odm_report/`
