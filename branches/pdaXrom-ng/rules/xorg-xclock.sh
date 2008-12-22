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

XORG_XCLOCK=xclock-1.0.3.tar.bz2
XORG_XCLOCK_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XCLOCK_DIR=$BUILD_DIR/xclock-1.0.3
XORG_XCLOCK_ENV=

build_xorg_xclock() {
    test -e "$STATE_DIR/xorg_xclock-1.0.3" && return
    banner "Build $XORG_XCLOCK"
    download $XORG_XCLOCK_MIRROR $XORG_XCLOCK
    extract $XORG_XCLOCK
    apply_patches $XORG_XCLOCK_DIR $XORG_XCLOCK
    pushd $TOP_DIR
    cd $XORG_XCLOCK_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XCLOCK_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 755 xclock $ROOTFS_DIR/usr/bin/xclock || error
    $STRIP $ROOTFS_DIR/usr/bin/xclock

    for f in XClock XClock-color ; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/share/X11/app-defaults/$f || error
    done

    popd
    touch "$STATE_DIR/xorg_xclock-1.0.3"
}

build_xorg_xclock
