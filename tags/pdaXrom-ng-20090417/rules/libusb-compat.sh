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

LIBUSB_COMPAT=libusb-compat-0.1.0.tar.bz2
LIBUSB_COMPAT_MIRROR=http://downloads.sourceforge.net/libusb
LIBUSB_COMPAT_DIR=$BUILD_DIR/libusb-compat-0.1.0
LIBUSB_COMPAT_ENV="$CROSS_ENV_AC"

build_libusb_compat() {
    test -e "$STATE_DIR/libusb_compat.installed" && return
    banner "Build libusb-compat"
    download $LIBUSB_COMPAT_MIRROR $LIBUSB_COMPAT
    extract $LIBUSB_COMPAT
    apply_patches $LIBUSB_COMPAT_DIR $LIBUSB_COMPAT
    pushd $TOP_DIR
    cd $LIBUSB_COMPAT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBUSB_COMPAT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 libusb/.libs/libusb-0.1.so.4.4.4 $ROOTFS_DIR/usr/lib/libusb-0.1.so.4.4.4 || error
    ln -sf libusb-0.1.so.4.4.4 $ROOTFS_DIR/usr/lib/libusb-0.1.so.4
    ln -sf libusb-0.1.so.4.4.4 $ROOTFS_DIR/usr/lib/libusb-0.1.so
    $STRIP $ROOTFS_DIR/usr/lib/libusb-0.1.so.4.4.4

    popd
    touch "$STATE_DIR/libusb_compat.installed"
}

build_libusb_compat
