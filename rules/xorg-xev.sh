#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

XORG_XEV_VERSION=1.0.3
XORG_XEV=xev-${XORG_XEV_VERSION}.tar.bz2
XORG_XEV_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XEV_DIR=$BUILD_DIR/xev-${XORG_XEV_VERSION}
XORG_XEV_ENV="$CROSS_ENV_AC"

build_xorg_xev() {
    test -e "$STATE_DIR/xorg_xev.installed" && return
    banner "Build xorg-xev"
    download $XORG_XEV_MIRROR $XORG_XEV
    extract $XORG_XEV
    apply_patches $XORG_XEV_DIR $XORG_XEV
    pushd $TOP_DIR
    cd $XORG_XEV_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XEV_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 xev $ROOTFS_DIR/usr/bin/xev || error
    $STRIP $ROOTFS_DIR/usr/bin/xev

    popd
    touch "$STATE_DIR/xorg_xev.installed"
}

build_xorg_xev
