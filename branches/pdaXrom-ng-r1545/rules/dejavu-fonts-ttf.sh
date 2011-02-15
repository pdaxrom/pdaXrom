#
# packet template
#
# Copyright (C) 2009 by Marina Popova <marika@tusur.info>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

DEJAVU_FONTS_TTF_VERSION=2.31
DEJAVU_FONTS_TTF=dejavu-fonts-ttf-${DEJAVU_FONTS_TTF_VERSION}.tar.bz2
DEJAVU_FONTS_TTF_MIRROR=http://downloads.sourceforge.net/project/dejavu/dejavu/2.31
DEJAVU_FONTS_TTF_DIR=$BUILD_DIR/dejavu-fonts-ttf-${DEJAVU_FONTS_TTF_VERSION}
DEJAVU_FONTS_TTF_ENV="$CROSS_ENV_AC"

build_dejavu_fonts_ttf() {
    test -e "$STATE_DIR/dejavu_fonts_ttf.installed" && return
    banner "Build dejavu-fonts-ttf"
    download $DEJAVU_FONTS_TTF_MIRROR $DEJAVU_FONTS_TTF
    extract $DEJAVU_FONTS_TTF
    apply_patches $DEJAVU_FONTS_TTF_DIR $DEJAVU_FONTS_TTF
    pushd $TOP_DIR
    cd $DEJAVU_FONTS_TTF_DIR/ttf

    find . -name "*.ttf" | while read f; do
	$INSTALL -D -m 644 $f $ROOTFS_DIR/usr/share/fonts/truetype/ttf-dejavu/$f || error
    done

    mkfontscale $ROOTFS_DIR/usr/share/fonts/truetype/ttf-dejavu || error
    mkfontdir $ROOTFS_DIR/usr/share/fonts/truetype/ttf-dejavu || error
    fc-cache $ROOTFS_DIR/usr/share/fonts/truetype/ttf-dejavu || error

    popd
    touch "$STATE_DIR/dejavu_fonts_ttf.installed"
}

build_dejavu_fonts_ttf
