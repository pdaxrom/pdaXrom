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

PIXMAN=pixman-0.13.2.tar.bz2
PIXMAN_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
PIXMAN_DIR=$BUILD_DIR/pixman-0.13.2
PIXMAN_ENV=

build_pixman() {
    test -e "$STATE_DIR/pixman-0.13.2" && return
    banner "Build $PIXMAN"
    download $PIXMAN_MIRROR $PIXMAN
    extract $PIXMAN
    apply_patches $PIXMAN_DIR $PIXMAN
    pushd $TOP_DIR
    cd $PIXMAN_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PIXMAN_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 pixman/.libs/libpixman-1.so.0.13.2 $ROOTFS_DIR/usr/lib/libpixman-1.so.0.13.2 || error
    ln -sf libpixman-1.so.0.13.2 $ROOTFS_DIR/usr/lib/libpixman-1.so.0
    ln -sf libpixman-1.so.0.13.2 $ROOTFS_DIR/usr/lib/libpixman-1.so
    $STRIP $ROOTFS_DIR/usr/lib/libpixman-1.so.0.13.2

    popd
    touch "$STATE_DIR/pixman-0.13.2"
}

build_pixman
