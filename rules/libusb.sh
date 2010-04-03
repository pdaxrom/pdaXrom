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

LIBUSB=libusb-1.0.2.tar.bz2
LIBUSB_MIRROR=http://downloads.sourceforge.net/libusb
LIBUSB_DIR=$BUILD_DIR/libusb-1.0.2
LIBUSB_ENV="$CROSS_ENV_AC"

build_libusb() {
    test -e "$STATE_DIR/libusb.installed" && return
    banner "Build libusb"
    download $LIBUSB_MIRROR $LIBUSB
    extract $LIBUSB
    apply_patches $LIBUSB_DIR $LIBUSB
    pushd $TOP_DIR
    cd $LIBUSB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBUSB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 libusb/.libs/libusb-1.0.so.0.0.0 $ROOTFS_DIR/usr/lib/libusb-1.0.so.0.0.0 || error
    ln -sf libusb-1.0.so.0.0.0 $ROOTFS_DIR/usr/lib/libusb-1.0.so.0
    ln -sf libusb-1.0.so.0.0.0 $ROOTFS_DIR/usr/lib/libusb-1.0.so
    $STRIP $ROOTFS_DIR/usr/lib/libusb-1.0.so.0.0.0

    popd
    touch "$STATE_DIR/libusb.installed"
}

build_libusb
