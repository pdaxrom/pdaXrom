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

LIBXFIXES=libXfixes-4.0.3.tar.bz2
LIBXFIXES_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/lib
LIBXFIXES_DIR=$BUILD_DIR/libXfixes-4.0.3
LIBXFIXES_ENV=

build_libXfixes() {
    test -e "$STATE_DIR/libXfixes-4.0.3" && return
    banner "Build $LIBXFIXES"
    download $LIBXFIXES_MIRROR $LIBXFIXES
    extract $LIBXFIXES
    apply_patches $LIBXFIXES_DIR $LIBXFIXES
    pushd $TOP_DIR
    cd $LIBXFIXES_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXFIXES_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 src/.libs/libXfixes.so.3.1.0 $ROOTFS_DIR/usr/lib/libXfixes.so.3.1.0 || error
    ln -sf libXfixes.so.3.1.0 $ROOTFS_DIR/usr/lib/libXfixes.so.3
    ln -sf libXfixes.so.3.1.0 $ROOTFS_DIR/usr/lib/libXfixes.so
    $STRIP $ROOTFS_DIR/usr/lib/libXfixes.so.3.1.0

    popd
    touch "$STATE_DIR/libXfixes-4.0.3"
}

build_libXfixes
