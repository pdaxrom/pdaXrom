#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

USB_MODESWITCH_VERSION=1.0.7
USB_MODESWITCH=usb_modeswitch-${USB_MODESWITCH_VERSION}.tar.bz2
USB_MODESWITCH_MIRROR=http://www.draisberghof.de/usb_modeswitch
USB_MODESWITCH_DIR=$BUILD_DIR/usb_modeswitch-${USB_MODESWITCH_VERSION}
USB_MODESWITCH_ENV="$CROSS_ENV_AC"

build_usb_modeswitch() {
    test -e "$STATE_DIR/usb_modeswitch.installed" && return
    banner "Build usb_modeswitch"
    download $USB_MODESWITCH_MIRROR $USB_MODESWITCH
    extract $USB_MODESWITCH
    apply_patches $USB_MODESWITCH_DIR $USB_MODESWITCH
    pushd $TOP_DIR
    cd $USB_MODESWITCH_DIR

    make $MAKEARGS clean || error
    make $MAKEARGS CC=${CROSS}gcc CCFLAGS="-L${TARGET_LIB} -Wl,-rpath-link,${TARGET_LIB} -lusb" STRIP="${STRIP}" || error

    $INSTALL -D -m 755 usb_modeswitch $ROOTFS_DIR/usr/sbin/usb_modeswitch || error
    $INSTALL -D -m 644 usb_modeswitch.conf $ROOTFS_DIR/etc/usb_modeswitch.conf || error
    $INSTALL -D -m 644 ${GENERICFS_DIR}/etc/udev/rules.d/90-zte.rules ${ROOTFS_DIR}/etc/udev/rules.d/90-zte.rules || error

    popd
    touch "$STATE_DIR/usb_modeswitch.installed"
}

build_usb_modeswitch
