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

XORG_MKFONTSCALE=mkfontscale-1.0.5.tar.bz2
XORG_MKFONTSCALE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_MKFONTSCALE_DIR=$BUILD_DIR/mkfontscale-1.0.5
XORG_MKFONTSCALE_ENV=

build_xorg_mkfontscale() {
    test -e "$STATE_DIR/xorg_mkfontscale-1.0.5" && return
    banner "Build $XORG_MKFONTSCALE"
    download $XORG_MKFONTSCALE_MIRROR $XORG_MKFONTSCALE
    extract $XORG_MKFONTSCALE
    apply_patches $XORG_MKFONTSCALE_DIR $XORG_MKFONTSCALE
    pushd $TOP_DIR
    cd $XORG_MKFONTSCALE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_MKFONTSCALE_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 mkfontscale $ROOTFS_DIR/usr/bin/mkfontscale || error
    $STRIP $ROOTFS_DIR/usr/bin/mkfontscale

    popd
    touch "$STATE_DIR/xorg_mkfontscale-1.0.5"
}

build_xorg_mkfontscale
