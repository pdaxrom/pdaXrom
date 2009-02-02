. $RULES_DIR/host_dbus.sh
. $RULES_DIR/host_dbus-glib.sh
. $RULES_DIR/dbus.sh

if [ "`get_kernel_subarch $TARGET_ARCH`" = "i386" -o \
     "`get_kernel_subarch $TARGET_ARCH`" = "powerpc" ]; then

. $RULES_DIR/pciutils.sh

fi

. $RULES_DIR/libusb.sh
. $RULES_DIR/libusb-compat.sh
. $RULES_DIR/usbutils.sh
. $RULES_DIR/dbus-glib.sh
. $RULES_DIR/hal.sh
. $RULES_DIR/hal-info.sh

. $RULES_DIR/pm-utils.sh
