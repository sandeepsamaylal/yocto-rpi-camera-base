#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/image-size.sh
#   ./scripts/image-size.sh [BUILD_DIR]
#   ./scripts/image-size.sh [BUILD_DIR] --machine <machine>
#   ./scripts/image-size.sh [BUILD_DIR] --image <image-name>
#
# Defaults:
#   BUILD_DIR: build-rpi4
#   MACHINE:   raspberrypi4-64
#   IMAGE:     rpi-camera-base-image

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="build-rpi4"
MACHINE="raspberrypi4-64"
IMAGE_NAME="rpi-camera-base-image"

usage() {
    cat <<EOF
Usage: $0 [BUILD_DIR] [--machine <machine>] [--image <image-name>]

Examples:
  $0
  $0 build-rpi4
  $0 build-rpi4 --machine raspberrypi4-64
  $0 build-rpi4 --image rpi-camera-base-image
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --machine)
            MACHINE="${2:-}"
            if [[ -z "${MACHINE}" ]]; then
                echo "Error: --machine requires a value"
                exit 1
            fi
            shift 2
            ;;
        --image)
            IMAGE_NAME="${2:-}"
            if [[ -z "${IMAGE_NAME}" ]]; then
                echo "Error: --image requires a value"
                exit 1
            fi
            shift 2
            ;;
        --*)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            BUILD_DIR="$1"
            shift
            ;;
    esac
done

DEPLOY_DIR="${REPO_DIR}/${BUILD_DIR}/tmp/deploy/images/${MACHINE}"
if [[ ! -d "${DEPLOY_DIR}" ]]; then
    echo "Error: deploy directory not found: ${DEPLOY_DIR}"
    exit 1
fi

shopt -s nullglob
candidates=(
    "${DEPLOY_DIR}/${IMAGE_NAME}-${MACHINE}"*.wic
    "${DEPLOY_DIR}/${IMAGE_NAME}-${MACHINE}"*.wic.bz2
    "${DEPLOY_DIR}/${IMAGE_NAME}-${MACHINE}"*.wic.gz
    "${DEPLOY_DIR}/${IMAGE_NAME}-${MACHINE}"*.sdimg
)
shopt -u nullglob

if [[ ${#candidates[@]} -eq 0 ]]; then
    echo "No matching image artifacts found for ${IMAGE_NAME} in ${DEPLOY_DIR}"
    exit 1
fi

human_size() {
    local bytes="$1"
    if command -v numfmt >/dev/null 2>&1; then
        numfmt --to=iec --suffix=B "${bytes}"
    else
        echo "${bytes}B"
    fi
}

echo "Image artifact sizes:"
for f in "${candidates[@]}"; do
    bytes="$(stat -c '%s' "${f}")"
    h="$(human_size "${bytes}")"
    printf "  %-70s %12s (%s bytes)\n" "$(basename "${f}")" "${h}" "${bytes}"
done
