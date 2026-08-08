SUMMARY = "Camera support packagegroup for Raspberry Pi camera bring-up"
DESCRIPTION = "Optional milestone-2 camera userspace packages"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    libcamera \
    libcamera-apps \
    v4l-utils \
"

# Include the external camera app when explicitly enabled.
RDEPENDS:${PN} += "${@bb.utils.contains('RPI_CAMERA_APP', '1', ' rpi-camera-rtsp-mqtt-app', '', d)}"
