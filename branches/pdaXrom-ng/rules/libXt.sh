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

LIBXT=libXt-1.0.5.tar.bz2
LIBXT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXT_DIR=$BUILD_DIR/libXt-1.0.5
LIBXT_ENV=

build_libXt() {
    test -e "$STATE_DIR/libXt-1.0.4" && return
    banner "Build $LIBXT"
    download $LIBXT_MIRROR $LIBXT
    extract $LIBXT
    apply_patches $LIBXT_DIR $LIBXT
    pushd $TOP_DIR
    cd $LIBXT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXT_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    --disable-install-makestrs \
	    --enable-xkb \
	    || error
    )
    make -C util $MAKEARGS || error
    
    $HOST_CC util/makestrs.c -o util/makestrs || error "makestrs"

    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXt.so.6.0.0 $ROOTFS_DIR/usr/lib/libXt.so.6.0.0 || error
    ln -sf libXt.so.6.0.0 $ROOTFS_DIR/usr/lib/libXt.so.6
    ln -sf libXt.so.6.0.0 $ROOTFS_DIR/usr/lib/libXt.so
    $STRIP $ROOTFS_DIR/usr/lib/libXt.so.6.0.0

    popd
    touch "$STATE_DIR/libXt-1.0.4"
}

build_libXt
