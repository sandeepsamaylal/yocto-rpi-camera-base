# Build Notes (Milestone 1)

This repository is for a minimal Raspberry Pi 4 Yocto image bring-up.

## Scope

1. Build image.
2. Boot Raspberry Pi 4.
3. Verify networking.
4. Verify SSH access.

## Prerequisites

- Ubuntu host with Yocto build dependencies installed.
- Yocto source tree (poky), meta-raspberrypi, and meta-openembedded.
- This repository cloned locally.

## Configure Build Directory

1. Initialize Yocto build environment from poky:
   - `source <YOCTO_DIR>/poky/oe-init-build-env <BUILD_DIR>`
2. Copy sample configs into `<BUILD_DIR>/conf/`:
   - `cp <REPO_DIR>/conf/local.conf.sample <BUILD_DIR>/conf/local.conf`
   - `cp <REPO_DIR>/conf/bblayers.conf.sample <BUILD_DIR>/conf/bblayers.conf`
3. Edit placeholders in `bblayers.conf`:
   - Replace `<YOCTO_DIR>` with your local Yocto source path.
   - Replace `<REPO_DIR>` with this repository path.

## Build

- `bitbake rpi-camera-base-image`

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
