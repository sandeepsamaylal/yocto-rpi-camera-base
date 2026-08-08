# Keep runtime rpicam shared object packaged to satisfy installed-vs-shipped QA.
FILES:${PN} += "${libdir}/rpicam_app.so.*"
