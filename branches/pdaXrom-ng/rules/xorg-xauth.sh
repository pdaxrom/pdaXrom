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

XORG_XAUTH=xauth-1.0.3.tar.bz2
XORG_XAUTH_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XAUTH_DIR=$BUILD_DIR/xauth-1.0.3
XORG_XAUTH_ENV=

build_xorg_xauth() {
    test -e "$STATE_DIR/xorg_xauth-1.0.3" && return
    banner "Build $XORG_XAUTH"
    download $XORG_XAUTH_MIRROR $XORG_XAUTH
    extract $XORG_XAUTH
    apply_patches $XORG_XAUTH_DIR $XORG_XAUTH
    pushd $TOP_DIR
    cd $XORG_XAUTH_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XAUTH_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 xauth $ROOTFS_DIR/usr/bin/xauth || error
    $STRIP $ROOTFS_DIR/usr/bin/xauth

    popd
    touch "$STATE_DIR/xorg_xauth-1.0.3"
}

build_xorg_xauth
