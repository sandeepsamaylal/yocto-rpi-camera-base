# Yocto Raspberry Pi Camera Base

Minimal Yocto base image repository for Raspberry Pi 4.

This repository is intentionally limited to the base Yocto structure and a minimal custom image. Camera, RTSP, MQTT, and application-specific pieces will be added in later milestones.

## Related Repositories

- Final project management repo (wiki, schedule, issues, manifest):
    - https://github.com/cu-ecen-aeld/final-project-sandeepsamaylal
- Yocto base image repo (this repo):
    - https://github.com/sandeepsamaylal/yocto-rpi-camera-base

## Target Hardware

- Raspberry Pi 4 Model B
- Raspberry Pi Camera V2.1

## Streaming and Messaging Architecture (Planned)

- Live video path:
    - Raspberry Pi Camera V2.1 -> libcamera/V4L2 -> camera streaming app -> RTSP server -> VLC/ffplay client
- MQTT scope (lightweight control/status only):
    - `camera/status`
    - `camera/stream/url`
    - `camera/control/start`
    - `camera/control/stop`
    - `camera/control/restart`
    - `camera/error`

## Milestone 1 Scope

1. Build a minimal Yocto image for Raspberry Pi 4.
2. Boot it on hardware.
3. Verify basic networking.
4. Verify SSH access.

## Camera Bring-Up Packages

Camera packagegroup support is enabled by default.

- Disable in `conf/local.conf` if needed: `RPI_CAMERA_SUPPORT = "0"`

Optional external app package integration is available via:

- `RPI_CAMERA_APP = "1"` (after app sources are buildable)
- `RPI_CAMERA_APP_SRCREV = "<full-git-commit-hash>"` for reproducible app builds

Optional GStreamer RTSP runtime package support is available via:

- `RPI_RTSP_SUPPORT = "1"` to include RTSP-related GStreamer packages
- `RPI_RTSP_SUPPORT = "0"` to disable RTSP packages for smaller milestone images

Optional MQTT runtime package support is available via:

- `RPI_MQTT_SUPPORT = "1"` to include Mosquitto broker, CLI clients, and runtime libs
- `RPI_MQTT_SUPPORT = "0"` to disable MQTT packages for smaller milestone images

## Yocto Source Layout

This repository is set up to use Git submodules under `sources/` for Yocto dependencies:

- `sources/poky`
- `sources/meta-openembedded`
- `sources/meta-raspberrypi`

Initialize them after clone:

- `git submodule update --init --recursive`

Pinned revision details are tracked in:

- `docs/submodule-locks.md`

## Containerized Build

Build with Docker (no extra Yocto package setup on host):

- `./scripts/docker-build.sh`

If private Git over SSH is needed, start `ssh-agent` and load a key on host before running the script.

Detailed workflow:

- `docs/docker-build.md`

## Flash Image to SD Card

Use the helper script to flash the latest built image to an SD card.

- Auto-detect latest image artifact and flash:
    - `./scripts/flash-sd.sh --device /dev/sdX`
- Specify build directory explicitly:
    - `./scripts/flash-sd.sh build-rpi4 --device /dev/sdX`
- Use a specific artifact path:
    - `./scripts/flash-sd.sh --device /dev/sdX --artifact build-rpi4/tmp/deploy/images/raspberrypi4-64/rpi-camera-base-image-raspberrypi4-64.rootfs.wic.bz2`
- Flash and try to eject/power off USB SD reader after completion:
    - `./scripts/flash-sd.sh --device /dev/sdX --eject`

The script supports `.wic`, `.wic.bz2`, and `.wic.gz` artifacts and requires typing `flash` before writing.
Double-check the target device path (`/dev/sdX`) because all data on that disk will be erased.

## Repository Layout

```text
yocto-rpi-camera-base/
├── README.md
├── conf/
│   ├── local.conf.sample
│   └── bblayers.conf.sample
├── docs/
│   └── build-notes.md
├── scripts/
│   └── build.sh
└── meta-rpi-camera/
        ├── conf/
        │   └── layer.conf
        └── recipes-core/
                ├── images/
                │   └── rpi-camera-base-image.bb
                └── packagegroups/
                        └── packagegroup-rpi-camera-base.bb
```
