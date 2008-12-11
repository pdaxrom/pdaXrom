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

LIBXXF86DGA=libXxf86dga-1.0.2.tar.bz2
LIBXXF86DGA_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXXF86DGA_DIR=$BUILD_DIR/libXxf86dga-1.0.2
LIBXXF86DGA_ENV=

build_libXxf86dga() {
    test -e "$STATE_DIR/libXxf86dga-1.0.2" && return
    banner "Build $LIBXXF86DGA"
    download $LIBXXF86DGA_MIRROR $LIBXXF86DGA
    extract $LIBXXF86DGA
    apply_patches $LIBXXF86DGA_DIR $LIBXXF86DGA
    pushd $TOP_DIR
    cd $LIBXXF86DGA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXXF86DGA_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 src/.libs/libXxf86dga.so.1.0.0 $ROOTFS_DIR/usr/lib/libXxf86dga.so.1.0.0 || error
    ln -sf libXxf86dga.so.1.0.0 $ROOTFS_DIR/usr/lib/libXxf86dga.so.1
    ln -sf libXxf86dga.so.1.0.0 $ROOTFS_DIR/usr/lib/libXxf86dga.so
    $STRIP $ROOTFS_DIR/usr/lib/libXxf86dga.so.1.0.0

    popd
    touch "$STATE_DIR/libXxf86dga-1.0.2"
}

build_libXxf86dga
