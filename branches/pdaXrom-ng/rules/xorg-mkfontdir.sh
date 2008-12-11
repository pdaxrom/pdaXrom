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

XORG_MKFONTDIR=mkfontdir-1.0.4.tar.bz2
XORG_MKFONTDIR_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_MKFONTDIR_DIR=$BUILD_DIR/mkfontdir-1.0.4
XORG_MKFONTDIR_ENV=

build_xorg_mkfontdir() {
    test -e "$STATE_DIR/xorg_mkfontdir-1.0.4" && return
    banner "Build $XORG_MKFONTDIR"
    download $XORG_MKFONTDIR_MIRROR $XORG_MKFONTDIR
    extract $XORG_MKFONTDIR
    apply_patches $XORG_MKFONTDIR_DIR $XORG_MKFONTDIR
    pushd $TOP_DIR
    cd $XORG_MKFONTDIR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_MKFONTDIR_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 mkfontdir $ROOTFS_DIR/usr/bin/mkfontdir || error

    popd
    touch "$STATE_DIR/xorg_mkfontdir-1.0.4"
}

build_xorg_mkfontdir
