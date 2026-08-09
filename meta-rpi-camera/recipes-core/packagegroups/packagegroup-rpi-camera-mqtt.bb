SUMMARY = "MQTT support packagegroup for Raspberry Pi camera project"
DESCRIPTION = "Mosquitto broker/client runtime packages for MQTT control and status"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    mosquitto \
    mosquitto-clients \
    libmosquitto1 \
    libmosquittopp1 \
"
