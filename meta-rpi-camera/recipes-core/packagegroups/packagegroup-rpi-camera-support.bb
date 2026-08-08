SUMMARY = "Camera support packagegroup for Raspberry Pi camera bring-up"
DESCRIPTION = "Optional milestone-2 camera userspace packages"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    libcamera \
    v4l-utils \
"
