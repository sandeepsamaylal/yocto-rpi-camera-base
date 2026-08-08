SUMMARY = "Minimal base image for Raspberry Pi 4 camera project"
DESCRIPTION = "Milestone-1 image for boot, networking, and SSH validation"
LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += "ssh-server-openssh"
IMAGE_INSTALL:append = " packagegroup-rpi-camera-base"

# Camera stack toggle (enabled by default in local.conf.sample).
# Set RPI_CAMERA_SUPPORT = "0" in local.conf to disable.
IMAGE_INSTALL:append = "${@bb.utils.contains('RPI_CAMERA_SUPPORT', '1', ' packagegroup-rpi-camera-support', '', d)}"
