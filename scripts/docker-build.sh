#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/docker-build.sh [BUILD_DIR]
# Example:
#   ./scripts/docker-build.sh
#   ./scripts/docker-build.sh build-rpi4

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${1:-build-rpi4}"

export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"

mkdir -p "${REPO_DIR}/cache/downloads" "${REPO_DIR}/cache/sstate-cache"

cd "${REPO_DIR}"

# Use cached downloads and sstate inside the workspace-mounted build directory.
if [[ ! -f conf/local.conf.sample ]]; then
    echo "Error: conf/local.conf.sample not found"
    exit 1
fi

echo "Building docker image and launching Yocto build..."
compose_cmd=(docker compose run --rm)

if [[ -n "${SSH_AUTH_SOCK:-}" && -S "${SSH_AUTH_SOCK}" ]]; then
    echo "Forwarding host SSH agent into container."
    compose_cmd+=(-e "SSH_AUTH_SOCK=/ssh-agent")
    compose_cmd+=(-v "${SSH_AUTH_SOCK}:/ssh-agent")
fi

if [[ -f "${HOME}/.ssh/known_hosts" ]]; then
    compose_cmd+=(-v "${HOME}/.ssh/known_hosts:/home/builder/.ssh/known_hosts:ro")
fi

"${compose_cmd[@]}" yocto-builder bash -lc "
    ./scripts/build.sh ${BUILD_DIR}
"
