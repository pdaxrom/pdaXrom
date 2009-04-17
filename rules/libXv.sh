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

LIBXV=libXv-1.0.4.tar.bz2
LIBXV_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXV_DIR=$BUILD_DIR/libXv-1.0.4
LIBXV_ENV=

build_libXv() {
    test -e "$STATE_DIR/libXv-1.0.3" && return
    banner "Build $LIBXV"
    download $LIBXV_MIRROR $LIBXV
    extract $LIBXV
    apply_patches $LIBXV_DIR $LIBXV
    pushd $TOP_DIR
    cd $LIBXV_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXV_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXv.so.1.0.0 $ROOTFS_DIR/usr/lib/libXv.so.1.0.0 || error
    ln -sf libXv.so.1.0.0 $ROOTFS_DIR/usr/lib/libXv.so.1
    ln -sf libXv.so.1.0.0 $ROOTFS_DIR/usr/lib/libXv.so
    $STRIP $ROOTFS_DIR/usr/lib/libXv.so.1.0.0

    popd
    touch "$STATE_DIR/libXv-1.0.3"
}

build_libXv
