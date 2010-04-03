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

XORG_FONT_UTIL=font-util-1.0.1.tar.bz2
XORG_FONT_UTIL_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/font
XORG_FONT_UTIL_DIR=$BUILD_DIR/font-util-1.0.1
XORG_FONT_UTIL_ENV=

build_xorg_font_util() {
    test -e "$STATE_DIR/xorg_font_util-1.0.1" && return
    banner "Build $XORG_FONT_UTIL"
    download $XORG_FONT_UTIL_MIRROR $XORG_FONT_UTIL
    extract $XORG_FONT_UTIL
    apply_patches $XORG_FONT_UTIL_DIR $XORG_FONT_UTIL
    pushd $TOP_DIR
    cd $XORG_FONT_UTIL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_FONT_UTIL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files

    popd
    touch "$STATE_DIR/xorg_font_util-1.0.1"
}

build_xorg_font_util
