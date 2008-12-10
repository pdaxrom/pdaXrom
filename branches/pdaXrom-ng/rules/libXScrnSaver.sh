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

LIBXSCRNSAVER=libXScrnSaver-1.1.2.tar.bz2
LIBXSCRNSAVER_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/lib
LIBXSCRNSAVER_DIR=$BUILD_DIR/libXScrnSaver-1.1.2
LIBXSCRNSAVER_ENV=

build_libXScrnSaver() {
    test -e "$STATE_DIR/libXScrnSaver-1.1.2" && return
    banner "Build $LIBXSCRNSAVER"
    download $LIBXSCRNSAVER_MIRROR $LIBXSCRNSAVER
    extract $LIBXSCRNSAVER
    apply_patches $LIBXSCRNSAVER_DIR $LIBXSCRNSAVER
    pushd $TOP_DIR
    cd $LIBXSCRNSAVER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXSCRNSAVER_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXss.so.1.0.0 $ROOTFS_DIR/usr/lib/libXss.so.1.0.0 || error
    ln -sf libXss.so.1.0.0 $ROOTFS_DIR/usr/lib/libXss.so.1
    ln -sf libXss.so.1.0.0 $ROOTFS_DIR/usr/lib/libXss.so
    $STRIP $ROOTFS_DIR/usr/lib/libXss.so.1.0.0

    popd
    touch "$STATE_DIR/libXScrnSaver-1.1.2"
}

build_libXScrnSaver
