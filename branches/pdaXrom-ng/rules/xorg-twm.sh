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

XORG_TWM=twm-1.0.4.tar.bz2
XORG_TWM_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_TWM_DIR=$BUILD_DIR/twm-1.0.4
XORG_TWM_ENV=

build_xorg_twm() {
    test -e "$STATE_DIR/xorg_twm-1.0.4" && return
    banner "Build $XORG_TWM"
    download $XORG_TWM_MIRROR $XORG_TWM
    extract $XORG_TWM
    apply_patches $XORG_TWM_DIR $XORG_TWM
    pushd $TOP_DIR
    cd $XORG_TWM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_TWM_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/twm $ROOTFS_DIR/usr/bin/twm || error
    $STRIP $ROOTFS_DIR/usr/bin/twm

    $INSTALL -D -m 644 src/system.twmrc $ROOTFS_DIR/usr/share/X11/twm/system.twmrc || error

    popd
    touch "$STATE_DIR/xorg_twm-1.0.4"
}

build_xorg_twm
