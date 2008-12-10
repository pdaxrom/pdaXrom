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

LIBXRENDER=libXrender-0.9.4.tar.bz2
LIBXRENDER_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/lib
LIBXRENDER_DIR=$BUILD_DIR/libXrender-0.9.4
LIBXRENDER_ENV=

build_libXrender() {
    test -e "$STATE_DIR/libXrender-0.9.4" && return
    banner "Build $LIBXRENDER"
    download $LIBXRENDER_MIRROR $LIBXRENDER
    extract $LIBXRENDER
    apply_patches $LIBXRENDER_DIR $LIBXRENDER
    pushd $TOP_DIR
    cd $LIBXRENDER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXRENDER_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXrender.so.1.3.0 $ROOTFS_DIR/usr/lib/libXrender.so.1.3.0 || error
    ln -sf libXrender.so.1.3.0 $ROOTFS_DIR/usr/lib/libXrender.so.1
    ln -sf libXrender.so.1.3.0 $ROOTFS_DIR/usr/lib/libXrender.so
    $STRIP $ROOTFS_DIR/usr/lib/libXrender.so.1.3.0

    popd
    touch "$STATE_DIR/libXrender-0.9.4"
}

build_libXrender
