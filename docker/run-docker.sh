#/bin/zsh

IMAGE_NAME="tspi:2.0"

# Check if image exists
if ! docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
    echo "Image $IMAGE_NAME not found. Building..."
    docker build -t $IMAGE_NAME -f docker/dockerfile .
fi

docker run \
  --privileged \
  --network host \
  -e http_proxy=http://127.0.0.1:7890 \
  -e https_proxy=http://127.0.0.1:7890 \
  --mount type=bind,source=/home/zane/Workspace/sdk/tspi/tspi_repo,target=/home/tspi \
  --name="tspiv2-dev" \
  --hostname tspi \
  -it \
  tspi:2.0
