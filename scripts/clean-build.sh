#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/clean-build.sh [BUILD_DIR]
#   ./scripts/clean-build.sh [BUILD_DIR] --all
#   ./scripts/clean-build.sh [BUILD_DIR] --cache
#   ./scripts/clean-build.sh [BUILD_DIR] --yes

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="build-rpi4"
REMOVE_CACHE=0
ASSUME_YES=0

usage() {
    cat <<EOF
Usage: $0 [BUILD_DIR] [--cache|--all] [--yes]

Options:
  --cache   Remove cache directories only (downloads + sstate-cache).
  --all     Remove build directory and cache directories.
  --yes     Skip confirmation prompt.
  -h, --help  Show this help message.

Defaults:
  BUILD_DIR defaults to "build-rpi4".
  Without --cache/--all, only the build directory is removed.
EOF
}

for arg in "$@"; do
    case "$arg" in
        -h|--help)
            usage
            exit 0
            ;;
        --cache)
            REMOVE_CACHE=1
            ;;
        --all)
            REMOVE_CACHE=1
            ;;
        --yes)
            ASSUME_YES=1
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

BUILD_PATH="${REPO_DIR}/${BUILD_DIR}"
CACHE_DOWNLOADS="${REPO_DIR}/cache/downloads"
CACHE_SSTATE="${REPO_DIR}/cache/sstate-cache"

targets=()
if [[ -e "${BUILD_PATH}" ]]; then
    targets+=("${BUILD_PATH}")
fi

if [[ ${REMOVE_CACHE} -eq 1 ]]; then
    [[ -e "${CACHE_DOWNLOADS}" ]] && targets+=("${CACHE_DOWNLOADS}")
    [[ -e "${CACHE_SSTATE}" ]] && targets+=("${CACHE_SSTATE}")
fi

if [[ ${#targets[@]} -eq 0 ]]; then
    echo "Nothing to clean."
    exit 0
fi

echo "Will remove:"
for t in "${targets[@]}"; do
    echo "  - ${t}"
done

if [[ ${ASSUME_YES} -ne 1 ]]; then
    read -r -p "Proceed? [y/N] " reply
    if [[ ! "${reply}" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

for t in "${targets[@]}"; do
    if [[ "${t}" == "${REPO_DIR}" || "${t}" == "/" ]]; then
        echo "Refusing to remove unsafe path: ${t}"
        exit 1
    fi
    rm -rf "${t}"
done

echo "Cleanup complete."