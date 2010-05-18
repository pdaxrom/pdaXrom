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

LIBUSB_COMPAT=libusb-compat-0.1.3.tar.bz2
LIBUSB_COMPAT_MIRROR=http://downloads.sourceforge.net/libusb
LIBUSB_COMPAT_DIR=$BUILD_DIR/libusb-compat-0.1.3
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

    install_fakeroot_init
    rm -rf fakeroot/usr/bin
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libusb_compat.installed"
}

build_libusb_compat
