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

XBITMAPS=xbitmaps-1.0.1.tar.bz2
XBITMAPS_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/data
XBITMAPS_DIR=$BUILD_DIR/xbitmaps-1.0.1
XBITMAPS_ENV=

build_xbitmaps() {
    test -e "$STATE_DIR/xbitmaps-1.0.1" && return
    banner "Build $XBITMAPS"
    download $XBITMAPS_MIRROR $XBITMAPS
    extract $XBITMAPS
    apply_patches $XBITMAPS_DIR $XBITMAPS
    pushd $TOP_DIR
    cd $XBITMAPS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XBITMAPS_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/xbitmaps-1.0.1"
}

build_xbitmaps
