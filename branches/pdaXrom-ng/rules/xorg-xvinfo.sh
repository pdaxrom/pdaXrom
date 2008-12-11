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

XORG_XVINFO=xvinfo-1.0.2.tar.bz2
XORG_XVINFO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XVINFO_DIR=$BUILD_DIR/xvinfo-1.0.2
XORG_XVINFO_ENV=

build_xorg_xvinfo() {
    test -e "$STATE_DIR/xorg_xvinfo-1.0.2" && return
    banner "Build $XORG_XVINFO"
    download $XORG_XVINFO_MIRROR $XORG_XVINFO
    extract $XORG_XVINFO
    apply_patches $XORG_XVINFO_DIR $XORG_XVINFO
    pushd $TOP_DIR
    cd $XORG_XVINFO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XVINFO_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 xvinfo $ROOTFS_DIR/usr/bin/xvinfo || error
    $STRIP $ROOTFS_DIR/usr/bin/xvinfo

    popd
    touch "$STATE_DIR/xorg_xvinfo-1.0.2"
}

build_xorg_xvinfo
