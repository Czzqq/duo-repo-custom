#/bin/zsh

IMAGE_NAME="tspi:3.0"

# Check if image exists
if ! docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
    echo "Image $IMAGE_NAME not found. Building..."
    docker build -t $IMAGE_NAME -f docker/dockerfile .
fi

docker run \
  --privileged \
  --network host \
  -e http_proxy=http://192.168.0.191:7890 \
  -e https_proxy=http://192.168.0.191:7890 \
  --mount type=bind,source=/home/zane/Workspace/project/tspi/linux_sdk/tspi-kernel6.1-sdk,target=/home/tspi \
  --name="tspiv3-dev" \
  --hostname tspi \
  -it \
  tspi:3.0
