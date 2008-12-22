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

XORG_XEYES=xeyes-1.0.1.tar.bz2
XORG_XEYES_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XEYES_DIR=$BUILD_DIR/xeyes-1.0.1
XORG_XEYES_ENV=

build_xorg_xeyes() {
    test -e "$STATE_DIR/xorg_xeyes-1.0.1" && return
    banner "Build $XORG_XEYES"
    download $XORG_XEYES_MIRROR $XORG_XEYES
    extract $XORG_XEYES
    apply_patches $XORG_XEYES_DIR $XORG_XEYES
    pushd $TOP_DIR
    cd $XORG_XEYES_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XEYES_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 xeyes $ROOTFS_DIR/usr/bin/xeyes || error
    $STRIP $ROOTFS_DIR/usr/bin/xeyes

    popd
    touch "$STATE_DIR/xorg_xeyes-1.0.1"
}

build_xorg_xeyes
