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

LIBXTST=libXtst-1.0.3.tar.bz2
LIBXTST_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/lib
LIBXTST_DIR=$BUILD_DIR/libXtst-1.0.3
LIBXTST_ENV=

build_libXtst() {
    test -e "$STATE_DIR/libXtst-1.0.3" && return
    banner "Build $LIBXTST"
    download $LIBXTST_MIRROR $LIBXTST
    extract $LIBXTST
    apply_patches $LIBXTST_DIR $LIBXTST
    pushd $TOP_DIR
    cd $LIBXTST_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXTST_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXtst.so.6.1.0 $ROOTFS_DIR/usr/lib/libXtst.so.6.1.0 || error
    ln -sf libXtst.so.6.1.0 $ROOTFS_DIR/usr/lib/libXtst.so.6
    ln -sf libXtst.so.6.1.0 $ROOTFS_DIR/usr/lib/libXtst.so
    $STRIP $ROOTFS_DIR/usr/lib/libXtst.so.6.1.0

    popd
    touch "$STATE_DIR/libXtst-1.0.3"
}

build_libXtst
