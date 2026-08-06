#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/build.sh <YOCTO_DIR> [BUILD_DIR]
# Example:
#   ./scripts/build.sh ~/yocto build-rpi4

YOCTO_DIR="${1:-}"
BUILD_DIR="${2:-build-rpi4}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -z "${YOCTO_DIR}" ]]; then
    echo "Usage: $0 <YOCTO_DIR> [BUILD_DIR]"
    exit 1
fi

if [[ ! -f "${YOCTO_DIR}/poky/oe-init-build-env" ]]; then
    echo "Error: ${YOCTO_DIR}/poky/oe-init-build-env not found"
    exit 1
fi

# shellcheck disable=SC1090
source "${YOCTO_DIR}/poky/oe-init-build-env" "${BUILD_DIR}"

if [[ ! -f conf/local.conf ]]; then
    cp "${REPO_DIR}/conf/local.conf.sample" conf/local.conf
fi

if [[ ! -f conf/bblayers.conf ]]; then
    cp "${REPO_DIR}/conf/bblayers.conf.sample" conf/bblayers.conf
    sed -i "s|<YOCTO_DIR>|${YOCTO_DIR}|g" conf/bblayers.conf
    sed -i "s|<REPO_DIR>|${REPO_DIR}|g" conf/bblayers.conf
fi

echo "Building rpi-camera-base-image..."
bitbake rpi-camera-base-image
