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

XORG_FONT_TTF_BITSTREAM_VERA=ttf-bitstream-vera-1.10.tar.bz2
XORG_FONT_TTF_BITSTREAM_VERA_MIRROR=http://ftp.acc.umu.se/pub/GNOME/sources/ttf-bitstream-vera/1.10
XORG_FONT_TTF_BITSTREAM_VERA_DIR=$BUILD_DIR/ttf-bitstream-vera-1.10
XORG_FONT_TTF_BITSTREAM_VERA_ENV="$CROSS_ENV_AC"

build_xorg_font_ttf_bitstream_vera() {
    test -e "$STATE_DIR/xorg_font_ttf_bitstream_vera.installed" && return
    banner "Build xorg-font-ttf-bitstream-vera"
    download $XORG_FONT_TTF_BITSTREAM_VERA_MIRROR $XORG_FONT_TTF_BITSTREAM_VERA
    extract $XORG_FONT_TTF_BITSTREAM_VERA
    pushd $TOP_DIR
    cd $XORG_FONT_TTF_BITSTREAM_VERA_DIR

    find . -name "*.ttf" | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/share/fonts/truetype/$f || error
    done

    mkfontscale $ROOTFS_DIR/usr/share/fonts/truetype || error
    mkfontdir $ROOTFS_DIR/usr/share/fonts/truetype || error
    fc-cache $ROOTFS_DIR/usr/share/fonts/truetype || error

    popd
    touch "$STATE_DIR/xorg_font_ttf_bitstream_vera.installed"
}

build_xorg_font_ttf_bitstream_vera
