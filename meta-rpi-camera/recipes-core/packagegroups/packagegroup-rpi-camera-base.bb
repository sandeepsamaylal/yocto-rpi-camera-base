SUMMARY = "Minimal packagegroup for Raspberry Pi camera project"
DESCRIPTION = "Packages for basic network and SSH validation in milestone 1"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    packagegroup-core-boot \
    iproute2 \
    iputils \
    openssh \
    openssh-sftp-server \
"
