SUMMARY = "Minimal base image for Raspberry Pi 4 camera project"
DESCRIPTION = "Milestone-1 image for boot, networking, and SSH validation"
LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += "ssh-server-openssh"
IMAGE_INSTALL:append = " packagegroup-rpi-camera-base"
