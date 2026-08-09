# Explicitly keep broker startup enabled when included in the image.
# Works with both systemd and SysV init images.
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
INITSCRIPT_PARAMS = "defaults 30"
