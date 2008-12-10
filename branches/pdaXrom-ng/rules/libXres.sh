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

LIBXRES=libXres-1.0.3.tar.bz2
LIBXRES_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/lib
LIBXRES_DIR=$BUILD_DIR/libXres-1.0.3
LIBXRES_ENV=

build_libXres() {
    test -e "$STATE_DIR/libXres-1.0.3" && return
    banner "Build $LIBXRES"
    download $LIBXRES_MIRROR $LIBXRES
    extract $LIBXRES
    apply_patches $LIBXRES_DIR $LIBXRES
    pushd $TOP_DIR
    cd $LIBXRES_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXRES_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXRes.so.1.0.0 $ROOTFS_DIR/usr/lib/libXRes.so.1.0.0 || error
    ln -sf libXRes.so.1.0.0 $ROOTFS_DIR/usr/lib/libXRes.so.1
    ln -sf libXRes.so.1.0.0 $ROOTFS_DIR/usr/lib/libXRes.so
    $STRIP $ROOTFS_DIR/usr/lib/libXRes.so.1.0.0

    popd
    touch "$STATE_DIR/libXres-1.0.3"
}

build_libXres
