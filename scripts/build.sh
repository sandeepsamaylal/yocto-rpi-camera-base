#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/build.sh [BUILD_DIR]
#   ./scripts/build.sh <YOCTO_DIR> [BUILD_DIR]
# Example:
#   ./scripts/build.sh
#   ./scripts/build.sh build-rpi4
#   ./scripts/build.sh ~/yocto-sources build-rpi4

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_YOCTO_DIR="${REPO_DIR}/sources"
SYNC_CONF="${SYNC_CONF:-1}"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $0 [BUILD_DIR]"
    echo "       $0 <YOCTO_DIR> [BUILD_DIR]"
    echo
    echo "Defaults to submodule layout at ${DEFAULT_YOCTO_DIR}."
    exit 0
fi

if [[ $# -eq 0 ]]; then
    YOCTO_DIR="${DEFAULT_YOCTO_DIR}"
    BUILD_DIR="build-rpi4"
elif [[ $# -eq 1 ]]; then
    if [[ -f "${1}/poky/oe-init-build-env" ]]; then
        YOCTO_DIR="${1}"
        BUILD_DIR="build-rpi4"
    else
        YOCTO_DIR="${DEFAULT_YOCTO_DIR}"
        BUILD_DIR="${1}"
    fi
else
    YOCTO_DIR="${1}"
    BUILD_DIR="${2}"
fi

if [[ -f "${REPO_DIR}/.gitmodules" && "${YOCTO_DIR}" == "${DEFAULT_YOCTO_DIR}" ]]; then
    echo "Initializing submodules..."
    git -C "${REPO_DIR}" submodule update --init --recursive
fi

if [[ ! -f "${YOCTO_DIR}/poky/oe-init-build-env" ]]; then
    echo "Error: ${YOCTO_DIR}/poky/oe-init-build-env not found"
    echo "Hint: add submodules under ${REPO_DIR}/sources or pass a custom YOCTO_DIR"
    exit 1
fi

# shellcheck disable=SC1090
set +u
source "${YOCTO_DIR}/poky/oe-init-build-env" "${BUILD_DIR}"
set -u

if [[ "${SYNC_CONF}" == "1" ]]; then
    cp "${REPO_DIR}/conf/local.conf.sample" conf/local.conf
    cp "${REPO_DIR}/conf/bblayers.conf.sample" conf/bblayers.conf
    sed -i "s|<REPO_DIR>|${REPO_DIR}|g" conf/bblayers.conf
else
    echo "SYNC_CONF=0 detected, keeping existing conf/local.conf and conf/bblayers.conf"
fi

echo "Building rpi-camera-base-image..."
bitbake rpi-camera-base-image
