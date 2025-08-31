```sh
chmod +x gitea-verify-and-test.sh build-and-dev.sh
# or, from the project root:
# chmod +x scripts/gitea-verify-and-test.sh scripts/build-and-dev.sh
```

```sh
cd /home/jalcocert/Home-Lab/gitea/user-creator-fastapi
source .env
#export GITEA_BASE="http://192.168.1.11:3033"
#export GITEA_TOKEN="...admin token..."
export USER="yosua"
export OWNER="yosua"
export REPO="astro-payroll-solution-theme"
scripts/gitea-verify-and-test.sh
```

And this will listen and build:

```sh
BUILD_ROOT=/home/jalcocert
PROJECT="$BUILD_ROOT/BeyondAJourney/astro-news"
./build-and-dev.sh "$PROJECT"
```