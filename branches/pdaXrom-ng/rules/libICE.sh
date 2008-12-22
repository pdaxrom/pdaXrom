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

LIBICE=libICE-1.0.4.tar.bz2
LIBICE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBICE_DIR=$BUILD_DIR/libICE-1.0.4
LIBICE_ENV=

build_libICE() {
    test -e "$STATE_DIR/libICE-1.0.4" && return
    banner "Build $LIBICE"
    download $LIBICE_MIRROR $LIBICE
    extract $LIBICE
    apply_patches $LIBICE_DIR $LIBICE
    pushd $TOP_DIR
    cd $LIBICE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBICE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libICE.so.6.3.0 $ROOTFS_DIR/usr/lib/libICE.so.6.3.0 || error
    ln -sf libICE.so.6.3.0 $ROOTFS_DIR/usr/lib/libICE.so.6
    ln -sf libICE.so.6.3.0 $ROOTFS_DIR/usr/lib/libICE.so
    $STRIP $ROOTFS_DIR/usr/lib/libICE.so.6.3.0

    popd
    touch "$STATE_DIR/libICE-1.0.4"
}

build_libICE
