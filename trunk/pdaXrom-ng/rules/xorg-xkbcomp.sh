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

XORG_XKBCOMP=xkbcomp-1.0.5.tar.bz2
XORG_XKBCOMP_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XKBCOMP_DIR=$BUILD_DIR/xkbcomp-1.0.5
XORG_XKBCOMP_ENV=

build_xorg_xkbcomp() {
    test -e "$STATE_DIR/xorg_xkbcomp-1.0.5" && return
    banner "Build $XORG_XKBCOMP"
    download $XORG_XKBCOMP_MIRROR $XORG_XKBCOMP
    extract $XORG_XKBCOMP
    apply_patches $XORG_XKBCOMP_DIR $XORG_XKBCOMP
    pushd $TOP_DIR
    cd $XORG_XKBCOMP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XKBCOMP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 xkbcomp $ROOTFS_DIR/usr/bin/xkbcomp || error
    $STRIP $ROOTFS_DIR/usr/bin/xkbcomp || error

    popd
    touch "$STATE_DIR/xorg_xkbcomp-1.0.5"
}

build_xorg_xkbcomp
