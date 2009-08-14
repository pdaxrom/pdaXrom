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

XORG_XRDB=xrdb-1.0.5.tar.bz2
XORG_XRDB_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XRDB_DIR=$BUILD_DIR/xrdb-1.0.5
XORG_XRDB_ENV=

build_xorg_xrdb() {
    test -e "$STATE_DIR/xorg_xrdb-1.0.5" && return
    banner "Build $XORG_XRDB"
    download $XORG_XRDB_MIRROR $XORG_XRDB
    extract $XORG_XRDB
    apply_patches $XORG_XRDB_DIR $XORG_XRDB
    pushd $TOP_DIR
    cd $XORG_XRDB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XRDB_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 xrdb $ROOTFS_DIR/usr/bin/xrdb || error
    $STRIP $ROOTFS_DIR/usr/bin/xrdb

    popd
    touch "$STATE_DIR/xorg_xrdb-1.0.5"
}

build_xorg_xrdb
