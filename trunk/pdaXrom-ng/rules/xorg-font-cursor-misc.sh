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

XORG_FONT_CURSOR_MISC=font-cursor-misc-1.0.0.tar.bz2
XORG_FONT_CURSOR_MISC_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/font
XORG_FONT_CURSOR_MISC_DIR=$BUILD_DIR/font-cursor-misc-1.0.0
XORG_FONT_CURSOR_MISC_ENV=

build_xorg_font_cursor_misc() {
    test -e "$STATE_DIR/xorg_font_cursor_misc-1.0.0" && return
    banner "Build $XORG_FONT_CURSOR_MISC"
    download $XORG_FONT_CURSOR_MISC_MIRROR $XORG_FONT_CURSOR_MISC
    extract $XORG_FONT_CURSOR_MISC
    apply_patches $XORG_FONT_CURSOR_MISC_DIR $XORG_FONT_CURSOR_MISC
    pushd $TOP_DIR
    cd $XORG_FONT_CURSOR_MISC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_FONT_CURSOR_MISC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-top-fontdir=/usr/share/fonts \
	    || error
    )
    make $MAKEARGS || error

    mkdir -p $ROOTFS_DIR/usr/share/fonts/misc

    find . -name "*.pcf.gz" | while read f; do
	$INSTALL -m 644 $f $ROOTFS_DIR/usr/share/fonts/misc || error
    done

    cd $ROOTFS_DIR/usr/share/fonts/misc
    mkfontdir
    mkfontscale

    popd
    touch "$STATE_DIR/xorg_font_cursor_misc-1.0.0"
}

build_xorg_font_cursor_misc
