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

LIBPCIACCESS=libpciaccess-0.10.5.tar.bz2
LIBPCIACCESS_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBPCIACCESS_DIR=$BUILD_DIR/libpciaccess-0.10.5
LIBPCIACCESS_ENV=

build_libpciaccess() {
    test -e "$STATE_DIR/libpciaccess-0.10.5" && return
    banner "Build $LIBPCIACCESS"
    download $LIBPCIACCESS_MIRROR $LIBPCIACCESS
    extract $LIBPCIACCESS
    apply_patches $LIBPCIACCESS_DIR $LIBPCIACCESS
    pushd $TOP_DIR
    cd $LIBPCIACCESS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBPCIACCESS_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libpciaccess.so.0.10.2 $ROOTFS_DIR/usr/lib/libpciaccess.so.0.10.2 || error
    ln -sf libpciaccess.so.0.10.2 $ROOTFS_DIR/usr/lib/libpciaccess.so.0
    ln -sf libpciaccess.so.0.10.2 $ROOTFS_DIR/usr/lib/libpciaccess.so
    $STRIP $ROOTFS_DIR/usr/lib/libpciaccess.so.0.10.2
    
    popd
    touch "$STATE_DIR/libpciaccess-0.10.5"
}

build_libpciaccess
