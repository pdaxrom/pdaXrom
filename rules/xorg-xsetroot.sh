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

XORG_XSETROOT=xsetroot-1.0.2.tar.bz2
XORG_XSETROOT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XSETROOT_DIR=$BUILD_DIR/xsetroot-1.0.2
XORG_XSETROOT_ENV=

build_xorg_xsetroot() {
    test -e "$STATE_DIR/xorg_xsetroot-1.0.2" && return
    banner "Build $XORG_XSETROOT"
    download $XORG_XSETROOT_MIRROR $XORG_XSETROOT
    extract $XORG_XSETROOT
    apply_patches $XORG_XSETROOT_DIR $XORG_XSETROOT
    pushd $TOP_DIR
    cd $XORG_XSETROOT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XSETROOT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 xsetroot $ROOTFS_DIR/usr/bin/xsetroot || error
    $STRIP $ROOTFS_DIR/usr/bin/xsetroot

    popd
    touch "$STATE_DIR/xorg_xsetroot-1.0.2"
}

build_xorg_xsetroot
