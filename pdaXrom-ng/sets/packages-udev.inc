if [ -e $TOOLCHAIN_SYSROOT/lib/ld-uClibc.so.0 ]; then
. $RULES_DIR/udev-135.sh
else
. $RULES_DIR/host_gettext.sh
. $RULES_DIR/host_glib2.sh
. $RULES_DIR/zlib.sh
. $RULES_DIR/glib2.sh
. $RULES_DIR/attr.sh
. $RULES_DIR/acl.sh
. $RULES_DIR/libusb.sh
. $RULES_DIR/libusb-compat.sh
. $RULES_DIR/usbutils.sh
. $RULES_DIR/udev.sh
fi
