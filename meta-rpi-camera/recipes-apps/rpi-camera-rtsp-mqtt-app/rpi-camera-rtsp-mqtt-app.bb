SUMMARY = "Raspberry Pi camera RTSP/MQTT application"
DESCRIPTION = "Cross-compiled camera application package from external repository"
HOMEPAGE = "https://github.com/sandeepsamaylal/rpi-camera-rtsp-mqtt-app"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=eb1e9f7632353a33a427954331fbacfe"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Pin SRCREV to a fixed commit for reproducible builds once app development stabilizes.
SRC_URI = "git://github.com/sandeepsamaylal/rpi-camera-rtsp-mqtt-app.git;branch=main;protocol=https \
		   file://rpi-camera-rtsp-mqtt-app.service \
		   file://rpi-camera-rtsp-mqtt-app.init \
		   file://rpi-camera-rtsp-mqtt-app-launcher.sh \
		   file://rpi-camera-rtsp-mqtt-app.default"
# Default tracks latest main branch; override in local.conf with a full commit hash
# when you need a reproducible milestone build.
RPI_CAMERA_APP_SRCREV ?= "${AUTOREV}"
SRCREV = "${RPI_CAMERA_APP_SRCREV}"
PV = "1.0+git${SRCPV}"

S = "${WORKDIR}/git"

inherit cmake pkgconfig systemd update-rc.d

DEPENDS += "libcamera mosquitto"
RDEPENDS:${PN} += "libcamera libcamera-apps libmosquitto1 mosquitto-clients"

SYSTEMD_SERVICE:${PN} = "rpi-camera-rtsp-mqtt-app.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

INITSCRIPT_NAME = "rpi-camera-rtsp-mqtt-app"
INITSCRIPT_PARAMS = "defaults 97"

do_install:append() {
	install -d ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/rpi-camera-rtsp-mqtt-app.service ${D}${systemd_system_unitdir}/

	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/rpi-camera-rtsp-mqtt-app-launcher.sh ${D}${bindir}/rpi-camera-rtsp-mqtt-app-launcher

	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/rpi-camera-rtsp-mqtt-app.init ${D}${sysconfdir}/init.d/rpi-camera-rtsp-mqtt-app

	install -d ${D}${sysconfdir}/default
	install -m 0644 ${WORKDIR}/rpi-camera-rtsp-mqtt-app.default ${D}${sysconfdir}/default/rpi-camera-rtsp-mqtt-app
}

FILES:${PN} += " \
	${systemd_system_unitdir}/rpi-camera-rtsp-mqtt-app.service \
	${bindir}/rpi-camera-rtsp-mqtt-app-launcher \
	${sysconfdir}/init.d/rpi-camera-rtsp-mqtt-app \
	${sysconfdir}/default/rpi-camera-rtsp-mqtt-app \
"
