#!/bin/bash

set -euo pipefail

# Define the image name and container name
IMAGE_NAME="ubuntu:22.04"
CONTAINER_NAME="unizk"
HOST_FOLDER="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONTAINER_FOLDER="/UniZK"

if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    SOURCE_MOUNT="$(docker container inspect --format \
        '{{range .Mounts}}{{if eq .Destination "/UniZK"}}{{.Type}}:{{.Source}}:{{.RW}}{{end}}{{end}}' \
        "$CONTAINER_NAME")"

    if [[ "$SOURCE_MOUNT" != "bind:$HOST_FOLDER:true" ]]; then
        echo "Container '$CONTAINER_NAME' does not have the expected writable source mount at $CONTAINER_FOLDER." >&2
        echo "Stop and rename it to preserve its contents, then rerun this script:" >&2
        echo "  docker stop $CONTAINER_NAME" >&2
        echo "  docker rename $CONTAINER_NAME ${CONTAINER_NAME}-old" >&2
        exit 1
    fi

    if [[ "$(docker container inspect --format '{{.State.Running}}' "$CONTAINER_NAME")" != "true" ]]; then
        docker start "$CONTAINER_NAME"
    fi
else
    echo "Pulling the Ubuntu image..."
    docker pull "$IMAGE_NAME"

    echo "Creating and starting the container..."
    docker run --name "$CONTAINER_NAME" -d \
        --mount "type=bind,source=$HOST_FOLDER,target=$CONTAINER_FOLDER" \
        --workdir "$CONTAINER_FOLDER" \
        "$IMAGE_NAME" tail -f /dev/null
fi

echo "Installing dependencies, configuring Rust, and building RamSim..."
docker exec -it --workdir "$CONTAINER_FOLDER" "$CONTAINER_NAME" bash -c '
    set -euo pipefail

    bash dependency.sh
    source "$HOME/.cargo/env"
    rustup override set nightly

    cmake -S thirdparty/ramsim -B thirdparty/ramsim/build
    cmake --build thirdparty/ramsim/build --parallel "$(nproc)"

    echo "Setup complete. Opening a shell in $PWD..."
    exec bash -i
'
