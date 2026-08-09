SUMMARY = "RTSP support packagegroup for Raspberry Pi camera project"
DESCRIPTION = "GStreamer runtime packages for RTSP streaming integration"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    gstreamer1.0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-rtsp-server \
    rpi-camera-rtsp-relay \
"
