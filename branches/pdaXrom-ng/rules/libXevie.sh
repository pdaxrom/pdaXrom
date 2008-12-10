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

LIBXEVIE=libXevie-1.0.2.tar.bz2
LIBXEVIE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/lib
LIBXEVIE_DIR=$BUILD_DIR/libXevie-1.0.2
LIBXEVIE_ENV=

build_libXevie() {
    test -e "$STATE_DIR/libXevie-1.0.2" && return
    banner "Build $LIBXEVIE"
    download $LIBXEVIE_MIRROR $LIBXEVIE
    extract $LIBXEVIE
    apply_patches $LIBXEVIE_DIR $LIBXEVIE
    pushd $TOP_DIR
    cd $LIBXEVIE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXEVIE_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXevie.so.1.0.0 $ROOTFS_DIR/usr/lib/libXevie.so.1.0.0 || error
    ln -sf libXevie.so.1.0.0 $ROOTFS_DIR/usr/lib/libXevie.so.1
    ln -sf libXevie.so.1.0.0 $ROOTFS_DIR/usr/lib/libXevie.so
    $STRIP $ROOTFS_DIR/usr/lib/libXevie.so.1.0.0

    popd
    touch "$STATE_DIR/libXevie-1.0.2"
}

build_libXevie
