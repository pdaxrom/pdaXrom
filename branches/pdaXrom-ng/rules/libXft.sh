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

LIBXFT=libXft-2.1.13.tar.bz2
LIBXFT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXFT_DIR=$BUILD_DIR/libXft-2.1.13
LIBXFT_ENV=

build_libXft() {
    test -e "$STATE_DIR/libXft-2.1.12" && return
    banner "Build $LIBXFT"
    download $LIBXFT_MIRROR $LIBXFT
    extract $LIBXFT
    apply_patches $LIBXFT_DIR $LIBXFT
    pushd $TOP_DIR
    cd $LIBXFT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXFT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXft.so.2.1.13 $ROOTFS_DIR/usr/lib/libXft.so.2.1.13 || error
    ln -sf libXft.so.2.1.13 $ROOTFS_DIR/usr/lib/libXft.so.2
    ln -sf libXft.so.2.1.13 $ROOTFS_DIR/usr/lib/libXft.so
    $STRIP $ROOTFS_DIR/usr/lib/libXft.so.2.1.13

    ln -sf $TARGET_BIN_DIR/bin/xft-config $HOST_BIN_DIR/bin/ || error

    popd
    touch "$STATE_DIR/libXft-2.1.12"
}

build_libXft
