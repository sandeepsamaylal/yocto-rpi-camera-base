#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/clean-docker.sh
#   ./scripts/clean-docker.sh --all
#   ./scripts/clean-docker.sh --yes
#
# Behavior:
#   Default: remove this project's compose container and builder image.
#   --all:   additionally remove dangling images and stopped containers.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="yocto-rpi-camera-builder:scarthgap"
CONTAINER_NAME="yocto-rpi-camera-builder"
ASSUME_YES=0
REMOVE_ALL=0

usage() {
    cat <<EOF
Usage: $0 [--all] [--yes]

Options:
  --all      Also prune dangling images and stopped containers.
  --yes      Skip confirmation prompt.
  -h, --help Show this help message.

Default:
  Removes only this project's Docker container and image.
EOF
}

for arg in "$@"; do
    case "$arg" in
        --all)
            REMOVE_ALL=1
            ;;
        --yes)
            ASSUME_YES=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            usage
            exit 1
            ;;
    esac
done

if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker not found"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "Error: cannot access Docker daemon"
    exit 1
fi

echo "Docker cleanup plan:"
echo "  - docker compose down --remove-orphans"
echo "  - remove container if present: ${CONTAINER_NAME}"
echo "  - remove image if present: ${IMAGE_NAME}"
if [[ ${REMOVE_ALL} -eq 1 ]]; then
    echo "  - prune stopped containers"
    echo "  - prune dangling images"
fi

if [[ ${ASSUME_YES} -ne 1 ]]; then
    while true; do
        read -r -p "Proceed? [yes/no] " reply
        case "${reply}" in
            yes|y|Y|YES)
                break
                ;;
            no|n|N|NO|"")
                echo "Aborted."
                exit 0
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
fi

cd "${REPO_DIR}"
docker compose down --remove-orphans || true

if docker ps -a --format '{{.Names}}' | grep -xq "${CONTAINER_NAME}"; then
    docker rm -f "${CONTAINER_NAME}"
fi

if docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
    docker image rm "${IMAGE_NAME}"
fi

if [[ ${REMOVE_ALL} -eq 1 ]]; then
    docker container prune -f
    docker image prune -f
fi

echo "Docker cleanup complete."
