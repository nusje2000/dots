#!/bin/sh
# Run the dockerized IDE environment
# Usage: wget -qO /tmp/ide.sh https://raw.githubusercontent.com/nusje2000/dots/main/bin/run_ide.sh && sh /tmp/ide.sh
#   or:  curl -fsSL https://raw.githubusercontent.com/nusje2000/dots/main/bin/run_ide.sh -o /tmp/ide.sh && sh /tmp/ide.sh

set -e

IMAGE_NAME="nusje2000/ide"
IMAGE_TAG="latest"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

# Pull the image from Docker Hub
docker pull "$FULL_IMAGE"

# Resolve compose project name from the host directory so it stays
# consistent even though the container mounts it at /ide
COMPOSE_PROJECT="${DOCKER_COMPOSE_PROJECT_NAME:-$(basename "$(pwd)")}"

# Resolve git user from host config, args, or defaults
GIT_USER_NAME="${GIT_USER_NAME:-$(git config --global user.name 2>/dev/null || echo "Maarten Nusteling")}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-$(git config --global user.email 2>/dev/null || echo "maarten.nusteling@gmail.com")}"

# Forward X11 for clipboard support on Linux desktops
X11_ARGS=""
if [ -n "$DISPLAY" ]; then
    X11_ARGS="-e DISPLAY=${DISPLAY} -v /tmp/.X11-unix:/tmp/.X11-unix"
fi

echo "[ide] Starting IDE in $(pwd) (compose project: ${COMPOSE_PROJECT})..."
echo "[ide] Git user: ${GIT_USER_NAME} <${GIT_USER_EMAIL}>"
docker run -it --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd):/ide" \
    -v "${HOME}/.ssh:/home/ide/.ssh:ro" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT}" \
    -e "HOME=/home/ide" \
    -e "GIT_USER_NAME=${GIT_USER_NAME}" \
    -e "GIT_USER_EMAIL=${GIT_USER_EMAIL}" \
    $X11_ARGS \
    -w /ide \
    "$FULL_IMAGE"
