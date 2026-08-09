SUMMARY = "Minimal base image for Raspberry Pi 4 camera project"
DESCRIPTION = "Milestone-1 image for boot, networking, and SSH validation"
LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += "ssh-server-openssh"
IMAGE_INSTALL:append = " packagegroup-rpi-camera-base"

# Camera stack toggle (enabled by default in local.conf.sample).
# Set RPI_CAMERA_SUPPORT = "0" in local.conf to disable.
IMAGE_INSTALL:append = "${@bb.utils.contains('RPI_CAMERA_SUPPORT', '1', ' packagegroup-rpi-camera-support', '', d)}"

# RTSP stack toggle for sprint-3 streaming integration.
# Set RPI_RTSP_SUPPORT = "0" in local.conf to disable.
IMAGE_INSTALL:append = "${@bb.utils.contains('RPI_RTSP_SUPPORT', '1', ' packagegroup-rpi-camera-rtsp', '', d)}"

# MQTT stack toggle for control/status messaging integration.
# Set RPI_MQTT_SUPPORT = "0" in local.conf to disable.
IMAGE_INSTALL:append = "${@bb.utils.contains('RPI_MQTT_SUPPORT', '1', ' packagegroup-rpi-camera-mqtt', '', d)}"
