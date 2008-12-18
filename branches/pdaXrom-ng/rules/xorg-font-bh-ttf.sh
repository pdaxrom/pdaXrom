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

XORG_FONT_BH_TTF=font-bh-ttf-1.0.0.tar.bz2
XORG_FONT_BH_TTF_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/font
XORG_FONT_BH_TTF_DIR=$BUILD_DIR/font-bh-ttf-1.0.0
XORG_FONT_BH_TTF_ENV="$CROSS_ENV_AC"

build_xorg_font_bh_ttf() {
    test -e "$STATE_DIR/xorg_font_bh_ttf.installed" && return
    banner "Build xorg-font-bh-ttf"
    download $XORG_FONT_BH_TTF_MIRROR $XORG_FONT_BH_TTF
    extract $XORG_FONT_BH_TTF
    apply_patches $XORG_FONT_BH_TTF_DIR $XORG_FONT_BH_TTF
    pushd $TOP_DIR
    cd $XORG_FONT_BH_TTF_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_FONT_BH_TTF_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-top-fontdir=/usr/share/fonts \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    find . -name "*.ttf" | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/share/fonts/truetype/$f || error
    done

    mkfontscale $ROOTFS_DIR/usr/share/fonts/truetype || error
    mkfontdir $ROOTFS_DIR/usr/share/fonts/truetype || error
    fc-cache $ROOTFS_DIR/usr/share/fonts/truetype || error

    popd
    touch "$STATE_DIR/xorg_font_bh_ttf.installed"
}

build_xorg_font_bh_ttf
