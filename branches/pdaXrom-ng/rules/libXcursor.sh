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

LIBXCURSOR=libXcursor-1.1.9.tar.bz2
LIBXCURSOR_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/lib
LIBXCURSOR_DIR=$BUILD_DIR/libXcursor-1.1.9
LIBXCURSOR_ENV=

build_libXcursor() {
    test -e "$STATE_DIR/libXcursor-1.1.9" && return
    banner "Build $LIBXCURSOR"
    download $LIBXCURSOR_MIRROR $LIBXCURSOR
    extract $LIBXCURSOR
    apply_patches $LIBXCURSOR_DIR $LIBXCURSOR
    pushd $TOP_DIR
    cd $LIBXCURSOR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXCURSOR_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 src/.libs/libXcursor.so.1.0.2 $ROOTFS_DIR/usr/lib/libXcursor.so.1.0.2 || error
    ln -sf libXcursor.so.1.0.2 $ROOTFS_DIR/usr/lib/libXcursor.so.1
    ln -sf libXcursor.so.1.0.2 $ROOTFS_DIR/usr/lib/libXcursor.so
    $STRIP $ROOTFS_DIR/usr/lib/libXcursor.so.1.0.2

    popd
    touch "$STATE_DIR/libXcursor-1.1.9"
}

build_libXcursor
