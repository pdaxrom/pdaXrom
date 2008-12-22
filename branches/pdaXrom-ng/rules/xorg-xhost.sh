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

XORG_XHOST=xhost-1.0.2.tar.bz2
XORG_XHOST_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XHOST_DIR=$BUILD_DIR/xhost-1.0.2
XORG_XHOST_ENV=

build_xorg_xhost() {
    test -e "$STATE_DIR/xorg_xhost-1.0.2" && return
    banner "Build $XORG_XHOST"
    download $XORG_XHOST_MIRROR $XORG_XHOST
    extract $XORG_XHOST
    apply_patches $XORG_XHOST_DIR $XORG_XHOST
    pushd $TOP_DIR
    cd $XORG_XHOST_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XHOST_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    --disable-secure-rpc \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 xhost $ROOTFS_DIR/usr/bin/xhost || error
    $STRIP $ROOTFS_DIR/usr/bin/xhost

    popd
    touch "$STATE_DIR/xorg_xhost-1.0.2"
}

build_xorg_xhost
