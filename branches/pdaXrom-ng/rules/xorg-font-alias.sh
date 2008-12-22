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

XORG_FONT_ALIAS=font-alias-1.0.1.tar.bz2
XORG_FONT_ALIAS_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/font
XORG_FONT_ALIAS_DIR=$BUILD_DIR/font-alias-1.0.1
XORG_FONT_ALIAS_ENV=

build_xorg_font_alias() {
    test -e "$STATE_DIR/xorg_font_alias-1.0.1" && return
    banner "Build $XORG_FONT_ALIAS"
    download $XORG_FONT_ALIAS_MIRROR $XORG_FONT_ALIAS
    extract $XORG_FONT_ALIAS
    apply_patches $XORG_FONT_ALIAS_DIR $XORG_FONT_ALIAS
    pushd $TOP_DIR
    cd $XORG_FONT_ALIAS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_FONT_ALIAS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-top-fontdir=/usr/share/fonts \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    for f in 100dpi/fonts.alias 75dpi/fonts.alias cyrillic/fonts.alias misc/fonts.alias; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/share/fonts/$f
    done

    popd
    touch "$STATE_DIR/xorg_font_alias-1.0.1"
}

build_xorg_font_alias
