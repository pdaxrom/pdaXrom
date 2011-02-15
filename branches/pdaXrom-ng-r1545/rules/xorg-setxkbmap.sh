#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

XORG_SETXKBMAP_VERSION=1.0.4
XORG_SETXKBMAP=setxkbmap-${XORG_SETXKBMAP_VERSION}.tar.bz2
XORG_SETXKBMAP_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_SETXKBMAP_DIR=$BUILD_DIR/setxkbmap-${XORG_SETXKBMAP_VERSION}
XORG_SETXKBMAP_ENV="$CROSS_ENV_AC"

build_xorg_setxkbmap() {
    test -e "$STATE_DIR/xorg_setxkbmap.installed" && return
    banner "Build xorg-setxkbmap"
    download $XORG_SETXKBMAP_MIRROR $XORG_SETXKBMAP
    extract $XORG_SETXKBMAP
    apply_patches $XORG_SETXKBMAP_DIR $XORG_SETXKBMAP
    pushd $TOP_DIR
    cd $XORG_SETXKBMAP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_SETXKBMAP_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 setxkbmap $ROOTFS_DIR/usr/bin/setxkbmap || error
    $STRIP $ROOTFS_DIR/usr/bin/setxkbmap || error

    popd
    touch "$STATE_DIR/xorg_setxkbmap.installed"
}

build_xorg_setxkbmap
