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

LIBXRANDR=libXrandr-1.2.3.tar.bz2
LIBXRANDR_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXRANDR_DIR=$BUILD_DIR/libXrandr-1.2.3
LIBXRANDR_ENV=

build_libXrandr() {
    test -e "$STATE_DIR/libXrandr-1.2.2" && return
    banner "Build $LIBXRANDR"
    download $LIBXRANDR_MIRROR $LIBXRANDR
    extract $LIBXRANDR
    apply_patches $LIBXRANDR_DIR $LIBXRANDR
    pushd $TOP_DIR
    cd $LIBXRANDR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXRANDR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXrandr.so.2.1.0 $ROOTFS_DIR/usr/lib/libXrandr.so.2.1.0 || error
    ln -sf libXrandr.so.2.1.0 $ROOTFS_DIR/usr/lib/libXrandr.so.2
    ln -sf libXrandr.so.2.1.0 $ROOTFS_DIR/usr/lib/libXrandr.so
    $STRIP $ROOTFS_DIR/usr/lib/libXrandr.so.2.1.0

    popd
    touch "$STATE_DIR/libXrandr-1.2.2"
}

build_libXrandr
