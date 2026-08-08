SUMMARY = "Raspberry Pi camera RTSP/MQTT application"
DESCRIPTION = "Cross-compiled camera application package from external repository"
HOMEPAGE = "https://github.com/sandeepsamaylal/rpi-camera-rtsp-mqtt-app"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=eb1e9f7632353a33a427954331fbacfe"

# Pin SRCREV to a fixed commit for reproducible builds once app development stabilizes.
SRC_URI = "git://github.com/sandeepsamaylal/rpi-camera-rtsp-mqtt-app.git;branch=main;protocol=https"
# Default tracks latest main branch; override in local.conf with a full commit hash
# when you need a reproducible milestone build.
RPI_CAMERA_APP_SRCREV ?= "${AUTOREV}"
SRCREV = "${RPI_CAMERA_APP_SRCREV}"
PV = "1.0+git${SRCPV}"

S = "${WORKDIR}/git"

inherit cmake pkgconfig

DEPENDS += "libcamera"
RDEPENDS:${PN} += "libcamera v4l-utils"
