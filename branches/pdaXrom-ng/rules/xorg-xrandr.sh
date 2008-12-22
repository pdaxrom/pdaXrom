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

XORG_XRANDR=xrandr-1.2.3.tar.bz2
XORG_XRANDR_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XRANDR_DIR=$BUILD_DIR/xrandr-1.2.3
XORG_XRANDR_ENV=

build_xorg_xrandr() {
    test -e "$STATE_DIR/xorg_xrandr-1.2.3" && return
    banner "Build $XORG_XRANDR"
    download $XORG_XRANDR_MIRROR $XORG_XRANDR
    extract $XORG_XRANDR
    apply_patches $XORG_XRANDR_DIR $XORG_XRANDR
    pushd $TOP_DIR
    cd $XORG_XRANDR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XRANDR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 xrandr $ROOTFS_DIR/usr/bin/xrandr || error
    $STRIP $ROOTFS_DIR/usr/bin/xrandr

    popd
    touch "$STATE_DIR/xorg_xrandr-1.2.3"
}

build_xorg_xrandr
