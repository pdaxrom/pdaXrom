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

LIBXAU=libXau-1.0.3.tar.bz2
LIBXAU_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/lib
LIBXAU_DIR=$BUILD_DIR/libXau-1.0.3
LIBXAU_ENV=

build_libXau() {
    test -e "$STATE_DIR/libXau-1.0.3" && return
    banner "Build $LIBXAU"
    download $LIBXAU_MIRROR $LIBXAU
    extract $LIBXAU
    apply_patches $LIBXAU_DIR $LIBXAU
    pushd $TOP_DIR
    cd $LIBXAU_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXAU_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files

    $INSTALL -D -m 644 .libs/libXau.so.6.0.0 $ROOTFS_DIR/usr/lib/libXau.so.6.0.0
    ln -s libXau.so.6.0.0 $ROOTFS_DIR/usr/lib/libXau.so.6
    ln -s libXau.so.6.0.0 $ROOTFS_DIR/usr/lib/libXau.so
    $STRIP $ROOTFS_DIR/usr/lib/libXau.so.6.0.0

    popd
    touch "$STATE_DIR/libXau-1.0.3"
}

build_libXau
