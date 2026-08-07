# Build Notes (Milestone 1)

This repository is for a minimal Raspberry Pi 4 Yocto image bring-up.

## Scope

1. Build image.
2. Boot Raspberry Pi 4.
3. Verify networking.
4. Verify SSH access.

## Prerequisites

- Ubuntu host with Yocto build dependencies installed.
- This repository cloned locally.

## Initialize Yocto Submodules

This repository uses Git submodules under `sources/` for:

- poky
- meta-openembedded
- meta-raspberrypi

Run:

- `git submodule update --init --recursive`

## Configure Build Directory

1. Build using the helper script (defaults to `sources/` layout):
   - `./scripts/build.sh`
2. Optional: specify build directory name:
   - `./scripts/build.sh build-rpi4`
3. Optional: use external Yocto sources path instead of submodules:
   - `./scripts/build.sh <YOCTO_DIR> [BUILD_DIR]`

## Build

- `bitbake rpi-camera-base-image`

## Build in Docker (Alternative)

- `./scripts/docker-build.sh`

See `docs/docker-build.md` for details.

## Flash and Boot

- Use the generated `.wic.bz2` image from `tmp/deploy/images/raspberrypi4-64/`.
- Flash to microSD and boot Raspberry Pi 4.

## Verify Networking

On target:

- `ip a`
- `ip route`
- `ping -c 3 8.8.8.8`

## Verify SSH

From host:

- `ssh root@<rpi-ip>`

If SSH fails, verify:

- Ethernet/Wi-Fi link is up.
- Target IP address is correct.
- `ssh-server-openssh` is present in image features.
