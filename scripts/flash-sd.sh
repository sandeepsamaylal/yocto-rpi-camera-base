#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/flash-sd.sh --device /dev/sdX
#   ./scripts/flash-sd.sh build-rpi4 --device /dev/sdX
#   ./scripts/flash-sd.sh --device /dev/mmcblk0 --machine raspberrypi4-64
#   ./scripts/flash-sd.sh --device /dev/sdX --artifact /path/to/image.wic.bz2
#   ./scripts/flash-sd.sh --device /dev/sdX --yes
#   ./scripts/flash-sd.sh --device /dev/sdX --eject

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="build-rpi4"
MACHINE="raspberrypi4-64"
IMAGE_NAME="rpi-camera-base-image"
DEVICE=""
ARTIFACT=""
ASSUME_YES=0
EJECT_AFTER_FLASH=0

usage() {
        cat <<'EOF'
Usage: ./scripts/flash-sd.sh [BUILD_DIR] --device <disk> [options]

Options:
    --device <disk>      Target block device, e.g. /dev/sdb or /dev/mmcblk0 (required)
    --artifact <path>    Image artifact path (.wic, .wic.bz2, .wic.gz). If omitted, newest matching
                                             artifact from build deploy directory is selected automatically.
    --machine <machine>  Machine name used to locate deploy artifacts (default: raspberrypi4-64)
    --image <name>       Image recipe name prefix (default: rpi-camera-base-image)
    --eject              Power off/eject device after successful flashing (best effort).
    --yes                Skip confirmation prompt.
    -h, --help           Show this help message.

Examples:
    ./scripts/flash-sd.sh --device /dev/sdb
    ./scripts/flash-sd.sh build-rpi4 --device /dev/sdb
    ./scripts/flash-sd.sh --device /dev/mmcblk0 --machine raspberrypi4-64
    ./scripts/flash-sd.sh --device /dev/sdb --artifact build-rpi4/tmp/deploy/images/raspberrypi4-64/rpi-camera-base-image-raspberrypi4-64.rootfs.wic.bz2
    ./scripts/flash-sd.sh --device /dev/sdb --eject
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --device)
            DEVICE="${2:-}"
            if [[ -z "${DEVICE}" ]]; then
                echo "Error: --device requires a value"
                exit 1
            fi
            shift 2
            ;;
        --artifact)
            ARTIFACT="${2:-}"
            if [[ -z "${ARTIFACT}" ]]; then
                echo "Error: --artifact requires a value"
                exit 1
            fi
            shift 2
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
        --yes)
            ASSUME_YES=1
            shift
            ;;
        --eject)
            EJECT_AFTER_FLASH=1
            shift
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

if [[ -z "${DEVICE}" ]]; then
    echo "Error: --device is required"
    usage
    exit 1
fi

if [[ ! -b "${DEVICE}" ]]; then
    echo "Error: target device does not exist or is not a block device: ${DEVICE}"
    exit 1
fi

device_type="$(lsblk -dn -o TYPE "${DEVICE}" 2>/dev/null || true)"
if [[ "${device_type}" != "disk" ]]; then
    echo "Error: target must be a whole-disk block device (TYPE=disk), got TYPE='${device_type:-unknown}'"
    echo "Hint: use /dev/sdX or /dev/mmcblk0, not a partition like /dev/sdX1"
    exit 1
fi

root_source="$(findmnt -n -o SOURCE / || true)"
if [[ -n "${root_source}" && -b "${root_source}" ]]; then
    root_parent_name="$(lsblk -no PKNAME "${root_source}" 2>/dev/null || true)"
    if [[ -n "${root_parent_name}" ]]; then
        root_parent="/dev/${root_parent_name}"
        if [[ "${DEVICE}" == "${root_parent}" ]]; then
            echo "Error: refusing to flash the disk that hosts the current root filesystem: ${DEVICE}"
            exit 1
        fi
    fi
fi

if [[ -z "${ARTIFACT}" ]]; then
    DEPLOY_DIR="${REPO_DIR}/${BUILD_DIR}/tmp/deploy/images/${MACHINE}"
    if [[ ! -d "${DEPLOY_DIR}" ]]; then
        echo "Error: deploy directory not found: ${DEPLOY_DIR}"
        echo "Use --artifact <path> to specify an image manually."
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
        echo "Error: no matching artifacts found in ${DEPLOY_DIR}"
        echo "Tried prefixes: ${IMAGE_NAME}-${MACHINE}*.wic[.bz2|.gz], *.sdimg"
        exit 1
    fi

    newest="$(ls -1t "${candidates[@]}" | head -n 1)"
    ARTIFACT="${newest}"
fi

if [[ ! -f "${ARTIFACT}" ]]; then
    echo "Error: artifact not found: ${ARTIFACT}"
    exit 1
fi

ARTIFACT_SOURCE="${ARTIFACT}"
if [[ -L "${ARTIFACT}" ]]; then
    ARTIFACT_SOURCE="$(readlink -f "${ARTIFACT}")"
fi

if ! command -v sudo >/dev/null 2>&1; then
    echo "Error: sudo is required to write raw block devices"
    exit 1
fi

artifact_bytes="$(stat -Lc '%s' "${ARTIFACT_SOURCE}")"
if command -v numfmt >/dev/null 2>&1; then
    artifact_human="$(numfmt --to=iec --suffix=B "${artifact_bytes}")"
else
    artifact_human="${artifact_bytes}B"
fi

device_size="$(lsblk -dn -o SIZE "${DEVICE}" 2>/dev/null || echo unknown)"
device_model="$(lsblk -dn -o MODEL "${DEVICE}" 2>/dev/null || true)"

echo "Selected artifact: ${ARTIFACT} (${artifact_human})"
if [[ "${ARTIFACT_SOURCE}" != "${ARTIFACT}" ]]; then
    echo "Resolved artifact: ${ARTIFACT_SOURCE}"
fi
echo "Target device:     ${DEVICE} (${device_size}${device_model:+, ${device_model}})"
echo ""
echo "WARNING: This will erase all data on ${DEVICE}."

if [[ ${ASSUME_YES} -ne 1 ]]; then
    read -r -p "Type 'flash' to continue: " confirm
    if [[ "${confirm}" != "flash" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

mapfile -t mounted_parts < <(lsblk -lnpo NAME,MOUNTPOINT "${DEVICE}" | awk 'NR > 1 && $2 != "" {print $1}')
for part in "${mounted_parts[@]}"; do
    echo "Unmounting ${part}"
    sudo umount "${part}"
done

case "${ARTIFACT_SOURCE}" in
    *.wic.bz2|*.sdimg.bz2)
        echo "Flashing compressed bzip2 image..."
        bzcat "${ARTIFACT_SOURCE}" | sudo dd of="${DEVICE}" bs=4M conv=fsync status=progress
        ;;
    *.wic.gz|*.sdimg.gz)
        echo "Flashing compressed gzip image..."
        gzip -dc "${ARTIFACT_SOURCE}" | sudo dd of="${DEVICE}" bs=4M conv=fsync status=progress
        ;;
    *)
        echo "Flashing raw image..."
        sudo dd if="${ARTIFACT_SOURCE}" of="${DEVICE}" bs=4M conv=fsync status=progress
        ;;
esac

sync
sudo partprobe "${DEVICE}" >/dev/null 2>&1 || true

if [[ ${EJECT_AFTER_FLASH} -eq 1 ]]; then
    echo "Attempting to eject/power off ${DEVICE}..."
    if command -v udisksctl >/dev/null 2>&1; then
        if udisksctl power-off -b "${DEVICE}" >/dev/null 2>&1; then
            echo "Device powered off via udisksctl: ${DEVICE}"
        elif sudo -n udisksctl power-off -b "${DEVICE}" >/dev/null 2>&1; then
            echo "Device powered off via udisksctl (sudo): ${DEVICE}"
        else
            echo "udisksctl power-off failed for ${DEVICE}; trying eject..."
            if command -v eject >/dev/null 2>&1; then
                if eject "${DEVICE}" >/dev/null 2>&1; then
                    echo "Device ejected: ${DEVICE}"
                elif sudo -n eject "${DEVICE}" >/dev/null 2>&1; then
                    echo "Device ejected via sudo: ${DEVICE}"
                else
                    echo "Warning: could not eject ${DEVICE}. You can remove it manually after ensuring writes are complete."
                fi
            else
                echo "Warning: eject command not found. Remove device manually after ensuring writes are complete."
            fi
        fi
    elif command -v eject >/dev/null 2>&1; then
        if eject "${DEVICE}" >/dev/null 2>&1; then
            echo "Device ejected: ${DEVICE}"
        elif sudo -n eject "${DEVICE}" >/dev/null 2>&1; then
            echo "Device ejected via sudo: ${DEVICE}"
        else
            echo "Warning: could not eject ${DEVICE}. You can remove it manually after ensuring writes are complete."
        fi
    else
        echo "Warning: neither udisksctl nor eject is available. Remove device manually after ensuring writes are complete."
    fi
fi

echo ""
echo "Flash complete: ${DEVICE}"
