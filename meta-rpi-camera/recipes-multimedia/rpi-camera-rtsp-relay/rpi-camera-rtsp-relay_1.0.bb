SUMMARY = "Local RTSP relay for Raspberry Pi camera stream"
DESCRIPTION = "Serves localhost UDP H264 stream as RTSP endpoint for LAN clients"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://rpi-camera-rtsp-relay.c \
           file://rpi-camera-rtsp-relay.service \
           file://rpi-camera-rtsp-relay.init \
           file://rpi-camera-rtsp-relay.default"

S = "${WORKDIR}"

inherit pkgconfig systemd update-rc.d

DEPENDS = "gstreamer1.0 gstreamer1.0-rtsp-server"
RDEPENDS:${PN} += "gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good"

SYSTEMD_SERVICE:${PN} = "rpi-camera-rtsp-relay.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

INITSCRIPT_NAME = "rpi-camera-rtsp-relay"
INITSCRIPT_PARAMS = "defaults 96"

do_compile() {
    ${CC} ${CFLAGS} ${CPPFLAGS} \
        $(pkg-config --cflags gstreamer-1.0 gstreamer-rtsp-server-1.0) \
        ${WORKDIR}/rpi-camera-rtsp-relay.c \
        -o rpi-camera-rtsp-relay \
        ${LDFLAGS} \
        $(pkg-config --libs gstreamer-1.0 gstreamer-rtsp-server-1.0)
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/rpi-camera-rtsp-relay ${D}${bindir}/rpi-camera-rtsp-relay

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/rpi-camera-rtsp-relay.service ${D}${systemd_system_unitdir}/

    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/rpi-camera-rtsp-relay.init ${D}${sysconfdir}/init.d/rpi-camera-rtsp-relay

    install -d ${D}${sysconfdir}/default
    install -m 0644 ${WORKDIR}/rpi-camera-rtsp-relay.default ${D}${sysconfdir}/default/rpi-camera-rtsp-relay
}

FILES:${PN} += " \
    ${systemd_system_unitdir}/rpi-camera-rtsp-relay.service \
    ${sysconfdir}/init.d/rpi-camera-rtsp-relay \
    ${sysconfdir}/default/rpi-camera-rtsp-relay \
"
