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

PIXMAN_VERSION=0.14.0
PIXMAN=pixman-${PIXMAN_VERSION}.tar.bz2
PIXMAN_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
PIXMAN_DIR=$BUILD_DIR/pixman-${PIXMAN_VERSION}
PIXMAN_ENV=

build_pixman() {
    test -e "$STATE_DIR/pixman-${PIXMAN_VERSION}" && return
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
    
    $INSTALL -D -m 644 pixman/.libs/libpixman-1.so.${PIXMAN_VERSION} $ROOTFS_DIR/usr/lib/libpixman-1.so.${PIXMAN_VERSION} || error
    ln -sf libpixman-1.so.${PIXMAN_VERSION} $ROOTFS_DIR/usr/lib/libpixman-1.so.0
    ln -sf libpixman-1.so.${PIXMAN_VERSION} $ROOTFS_DIR/usr/lib/libpixman-1.so
    $STRIP $ROOTFS_DIR/usr/lib/libpixman-1.so.${PIXMAN_VERSION}

    popd
    touch "$STATE_DIR/pixman-${PIXMAN_VERSION}"
}

build_pixman