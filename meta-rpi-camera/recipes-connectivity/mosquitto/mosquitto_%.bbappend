# Explicitly keep broker startup enabled when included in the image.
# Works with both systemd and SysV init images.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://10-listener.conf"

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
INITSCRIPT_PARAMS = "defaults 30"

do_install:append() {
	install -d ${D}${sysconfdir}/mosquitto/conf.d
	install -m 0644 ${WORKDIR}/10-listener.conf ${D}${sysconfdir}/mosquitto/conf.d/10-listener.conf

	conf_file="${D}${sysconfdir}/mosquitto/mosquitto.conf"
	if [ -f "$conf_file" ]; then
		if grep -q '^#include_dir$' "$conf_file"; then
			sed -i 's|^#include_dir$|include_dir /etc/mosquitto/conf.d|' "$conf_file"
		elif ! grep -q '^include_dir /etc/mosquitto/conf.d$' "$conf_file"; then
			echo 'include_dir /etc/mosquitto/conf.d' >> "$conf_file"
		fi
	fi
}

FILES:${PN} += "${sysconfdir}/mosquitto/conf.d/10-listener.conf"
CONFFILES:${PN} += "${sysconfdir}/mosquitto/conf.d/10-listener.conf"
