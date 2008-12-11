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

LIBXVMC=libXvMC-1.0.4.tar.bz2
LIBXVMC_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXVMC_DIR=$BUILD_DIR/libXvMC-1.0.4
LIBXVMC_ENV=

build_libXvMC() {
    test -e "$STATE_DIR/libXvMC-1.0.4" && return
    banner "Build $LIBXVMC"
    download $LIBXVMC_MIRROR $LIBXVMC
    extract $LIBXVMC
    apply_patches $LIBXVMC_DIR $LIBXVMC
    pushd $TOP_DIR
    cd $LIBXVMC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXVMC_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXvMC.so.1.0.0 $ROOTFS_DIR/usr/lib/libXvMC.so.1.0.0 || error
    ln -sf libXvMC.so.1.0.0 $ROOTFS_DIR/usr/lib/libXvMC.so.1
    ln -sf libXvMC.so.1.0.0 $ROOTFS_DIR/usr/lib/libXvMC.so
    $STRIP $ROOTFS_DIR/usr/lib/libXvMC.so.1.0.0
    
    $INSTALL -D -m 644 src/.libs/libXvMCW.so.1.0.0 $ROOTFS_DIR/usr/lib/libXvMCW.so.1.0.0 || error
    ln -sf libXvMCW.so.1.0.0 $ROOTFS_DIR/usr/lib/libXvMCW.so.1
    ln -sf libXvMCW.so.1.0.0 $ROOTFS_DIR/usr/lib/libXvMCW.so
    $STRIP $ROOTFS_DIR/usr/lib/libXvMCW.so.1.0.0

    popd
    touch "$STATE_DIR/libXvMC-1.0.4"
}

build_libXvMC
