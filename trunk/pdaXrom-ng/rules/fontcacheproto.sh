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

FONTCACHEPROTO=fontcacheproto-0.1.2.tar.bz2
FONTCACHEPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
FONTCACHEPROTO_DIR=$BUILD_DIR/fontcacheproto-0.1.2
FONTCACHEPROTO_ENV=

build_fontcacheproto() {
    test -e "$STATE_DIR/fontcacheproto-0.1.2" && return
    banner "Build $FONTCACHEPROTO"
    download $FONTCACHEPROTO_MIRROR $FONTCACHEPROTO
    extract $FONTCACHEPROTO
    apply_patches $FONTCACHEPROTO_DIR $FONTCACHEPROTO
    pushd $TOP_DIR
    cd $FONTCACHEPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$FONTCACHEPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/fontcacheproto-0.1.2"
}

build_fontcacheproto
