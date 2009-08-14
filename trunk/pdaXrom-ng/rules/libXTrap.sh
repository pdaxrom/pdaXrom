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

LIBXTRAP=libXTrap-1.0.0.tar.bz2
LIBXTRAP_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXTRAP_DIR=$BUILD_DIR/libXTrap-1.0.0
LIBXTRAP_ENV=

build_libXTrap() {
    test -e "$STATE_DIR/libXTrap-1.0.0" && return
    banner "Build $LIBXTRAP"
    download $LIBXTRAP_MIRROR $LIBXTRAP
    extract $LIBXTRAP
    apply_patches $LIBXTRAP_DIR $LIBXTRAP
    pushd $TOP_DIR
    cd $LIBXTRAP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXTRAP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error
    
    $INSTALL -D -m 644 src/.libs/libXTrap.so.6.4.0 $ROOTFS_DIR/usr/lib/libXTrap.so.6.4.0 || error
    ln -sf libXTrap.so.6.4.0 $ROOTFS_DIR/usr/lib/libXTrap.so.6
    ln -sf libXTrap.so.6.4.0 $ROOTFS_DIR/usr/lib/libXTrap.so
    $STRIP $ROOTFS_DIR/usr/lib/libXTrap.so.6.4.0

    popd
    touch "$STATE_DIR/libXTrap-1.0.0"
}

build_libXTrap
