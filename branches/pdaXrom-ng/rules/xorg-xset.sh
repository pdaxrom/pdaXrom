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

XORG_XSET=xset-1.0.4.tar.bz2
XORG_XSET_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XSET_DIR=$BUILD_DIR/xset-1.0.4
XORG_XSET_ENV=

build_xorg_xset() {
    test -e "$STATE_DIR/xorg_xset-1.0.4" && return
    banner "Build $XORG_XSET"
    download $XORG_XSET_MIRROR $XORG_XSET
    extract $XORG_XSET
    apply_patches $XORG_XSET_DIR $XORG_XSET
    pushd $TOP_DIR
    cd $XORG_XSET_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XSET_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 xset $ROOTFS_DIR/usr/bin/xset || error
    $STRIP $ROOTFS_DIR/usr/bin/xset

    popd
    touch "$STATE_DIR/xorg_xset-1.0.4"
}

build_xorg_xset
