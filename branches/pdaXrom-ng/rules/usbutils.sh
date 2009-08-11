#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

USBUTILS=usbutils-0.84.tar.gz
USBUTILS_MIRROR=http://downloads.sourceforge.net/linux-usb
USBUTILS_DIR=$BUILD_DIR/usbutils-0.84
USBUTILS_ENV="$CROSS_ENV_AC"

build_usbutils() {
    test -e "$STATE_DIR/usbutils.installed" && return
    banner "Build usbutils"
    download $USBUTILS_MIRROR $USBUTILS
    extract $USBUTILS
    apply_patches $USBUTILS_DIR $USBUTILS
    pushd $TOP_DIR
    cd $USBUTILS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$USBUTILS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share/hwdata \
	    --disable-zlib \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 usb.ids $ROOTFS_DIR/usr/share/hwdata/usb.ids || error
    $INSTALL -D -m 755 lsusb $ROOTFS_DIR/usr/sbin/lsusb || error
    $STRIP $ROOTFS_DIR/usr/sbin/lsusb

    popd
    touch "$STATE_DIR/usbutils.installed"
}

build_usbutils
