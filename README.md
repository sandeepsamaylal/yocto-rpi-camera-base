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

## Yocto Source Layout

This repository is set up to use Git submodules under `sources/` for Yocto dependencies:

- `sources/poky`
- `sources/meta-openembedded`
- `sources/meta-raspberrypi`

Initialize them after clone:

- `git submodule update --init --recursive`

Pinned revision details are tracked in:

- `docs/submodule-locks.md`

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
