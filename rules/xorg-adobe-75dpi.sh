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

XORG_ADOBE_75DPI=font-adobe-75dpi-1.0.0.tar.bz2
XORG_ADOBE_75DPI_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/font
XORG_ADOBE_75DPI_DIR=$BUILD_DIR/font-adobe-75dpi-1.0.0
XORG_ADOBE_75DPI_ENV=

build_xorg_adobe_75dpi() {
    test -e "$STATE_DIR/xorg_adobe_75dpi-1.0.0" && return
    banner "Build $XORG_ADOBE_75DPI"
    download $XORG_ADOBE_75DPI_MIRROR $XORG_ADOBE_75DPI
    extract $XORG_ADOBE_75DPI
    apply_patches $XORG_ADOBE_75DPI_DIR $XORG_ADOBE_75DPI
    pushd $TOP_DIR
    cd $XORG_ADOBE_75DPI_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_ADOBE_75DPI_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-top-fontdir=/usr/share/fonts \
	    || error
    )
    make $MAKEARGS || error

    mkdir -p $ROOTFS_DIR/usr/share/fonts/75dpi

    find . -name "*.pcf.gz" -a ! -name "*ISO8859*" -a ! -name "*KOI*" \
	-a ! -name "*ja*" -a ! -name "*ko*" -a ! -name "k14*" \
	-o -name "*ISO8859-1.pcf.gz" \
	-o -name "*ISO8859-15.pcf.gz" \
    | while read f; do
	$INSTALL -m 644 $f $ROOTFS_DIR/usr/share/fonts/75dpi || error
    done

    cd $ROOTFS_DIR/usr/share/fonts/75dpi
    mkfontdir
    mkfontscale

    popd
    touch "$STATE_DIR/xorg_adobe_75dpi-1.0.0"
}

build_xorg_adobe_75dpi
