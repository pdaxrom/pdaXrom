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

XORG_XKBDATA=xkbdata-1.0.1.tar.bz2
XORG_XKBDATA_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/data
XORG_XKBDATA_DIR=$BUILD_DIR/xkbdata-1.0.1
XORG_XKBDATA_ENV=

build_xorg_xkbdata() {
    test -e "$STATE_DIR/xorg_xkbdata-1.0.1" && return
    banner "Build $XORG_XKBDATA"
    download $XORG_XKBDATA_MIRROR $XORG_XKBDATA
    extract $XORG_XKBDATA
    apply_patches $XORG_XKBDATA_DIR $XORG_XKBDATA
    pushd $TOP_DIR
    cd $XORG_XKBDATA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XKBDATA_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    make $MAKEARGS DESTDIR=$ROOTFS_DIR install || error

    ln -sf xorg $ROOTFS_DIR/usr/share/X11/xkb/rules/base
    ln -sf xorg.lst $ROOTFS_DIR/usr/share/X11/xkb/rules/base.lst
    ln -sf xorg.xml $ROOTFS_DIR/usr/share/X11/xkb/rules/base.xml

    popd
    touch "$STATE_DIR/xorg_xkbdata-1.0.1"
}

build_xorg_xkbdata
