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

XORG_RGB=rgb-1.0.3.tar.bz2
XORG_RGB_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_RGB_DIR=$BUILD_DIR/rgb-1.0.3
XORG_RGB_ENV=

build_xorg_rgb() {
    test -e "$STATE_DIR/xorg_rgb-1.0.3" && return
    banner "Build $XORG_RGB"
    download $XORG_RGB_MIRROR $XORG_RGB
    extract $XORG_RGB
    apply_patches $XORG_RGB_DIR $XORG_RGB
    pushd $TOP_DIR
    cd $XORG_RGB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_RGB_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    )
    make $MAKEARGS || error

    $INSTALL -D -m 644 rgb.txt $ROOTFS_DIR/usr/share/X11/rgb.txt || error

    popd
    touch "$STATE_DIR/xorg_rgb-1.0.3"
}

build_xorg_rgb
