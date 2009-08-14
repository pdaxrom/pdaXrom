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

XORG_XINIT=xinit-1.1.0.tar.bz2
XORG_XINIT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XINIT_DIR=$BUILD_DIR/xinit-1.1.0
XORG_XINIT_ENV=

build_xorg_xinit() {
    test -e "$STATE_DIR/xorg_xinit-1.1.0" && return
    banner "Build $XORG_XINIT"
    download $XORG_XINIT_MIRROR $XORG_XINIT
    extract $XORG_XINIT
    apply_patches $XORG_XINIT_DIR $XORG_XINIT
    pushd $TOP_DIR
    cd $XORG_XINIT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XINIT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    --libdir=/etc \
	    --without-launchd \
	    || error
    )
    make $MAKEARGS XINITDIR=/etc/X11/xinit RAWCPP=${TARGET_ARCH}-cpp || error

    $INSTALL -D -m 755 xinit   $ROOTFS_DIR/usr/bin/xinit  || error "xinit"
    $STRIP $ROOTFS_DIR/usr/bin/xinit
    $INSTALL -D -m 755 startx  $ROOTFS_DIR/usr/bin/startx || error "startx"
    $INSTALL -D -m 755 xinitrc $ROOTFS_DIR/etc/X11/xinit/xinitrc  || error "xinitrc"

    popd
    touch "$STATE_DIR/xorg_xinit-1.1.0"
}

build_xorg_xinit
