#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/docker-sdk.sh
#   ./scripts/docker-sdk.sh --ext
#   ./scripts/docker-sdk.sh [BUILD_DIR]
#   ./scripts/docker-sdk.sh [BUILD_DIR] --ext
#
# Default target:
#   rpi-camera-base-image -c populate_sdk
#
# With --ext:
#   rpi-camera-base-image -c populate_sdk_ext

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="build-rpi4"
EXT_SDK=0

usage() {
    cat <<EOF
Usage: $0 [BUILD_DIR] [--ext]

Options:
  --ext      Build extensible SDK (populate_sdk_ext).
  -h, --help Show this help message.

Defaults:
  BUILD_DIR defaults to "build-rpi4".
  Without --ext, builds standard SDK (populate_sdk).
EOF
}

for arg in "$@"; do
    case "$arg" in
        --ext)
            EXT_SDK=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --*)
            echo "Unknown option: $arg"
            usage
            exit 1
            ;;
        *)
            BUILD_DIR="$arg"
            ;;
    esac
done

if [[ ! -f "${REPO_DIR}/scripts/docker-run.sh" ]]; then
    echo "Error: scripts/docker-run.sh not found"
    exit 1
fi

TASK="populate_sdk"
if [[ ${EXT_SDK} -eq 1 ]]; then
    TASK="populate_sdk_ext"
fi

echo "Generating SDK task '${TASK}' for build dir '${BUILD_DIR}'..."
"${REPO_DIR}/scripts/docker-run.sh" bash -lc "
    source sources/poky/oe-init-build-env ${BUILD_DIR} >/dev/null
    bitbake rpi-camera-base-image -c ${TASK}
"

echo "SDK artifacts are in: ${REPO_DIR}/${BUILD_DIR}/tmp/deploy/sdk"
