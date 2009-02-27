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

LIBXI_VERSION=1.2.1
LIBXI=libXi-${LIBXI_VERSION}.tar.bz2
LIBXI_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXI_DIR=$BUILD_DIR/libXi-${LIBXI_VERSION}
LIBXI_ENV=

build_libXi() {
    test -e "$STATE_DIR/libXi-${LIBXI_VERSION}" && return
    banner "Build $LIBXI"
    download $LIBXI_MIRROR $LIBXI
    extract $LIBXI
    apply_patches $LIBXI_DIR $LIBXI
    pushd $TOP_DIR
    cd $LIBXI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXI_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-man-pages \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error "build"

    install_sysroot_files || error "install"
    
    $INSTALL -D -m 644 src/.libs/libXi.so.6.0.0 $ROOTFS_DIR/usr/lib/libXi.so.6.0.0 || error "rootfs"
    ln -sf libXi.so.6.0.0 $ROOTFS_DIR/usr/lib/libXi.so.6
    ln -sf libXi.so.6.0.0 $ROOTFS_DIR/usr/lib/libXi.so
    $STRIP $ROOTFS_DIR/usr/lib/libXi.so.6.0.0

    popd
    touch "$STATE_DIR/libXi-${LIBXI_VERSION}"
}

build_libXi
