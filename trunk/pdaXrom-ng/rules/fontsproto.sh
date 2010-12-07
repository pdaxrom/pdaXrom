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

FONTSPROTO_VERSION=2.1.1
FONTSPROTO=fontsproto-${FONTSPROTO_VERSION}.tar.bz2
FONTSPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
FONTSPROTO_DIR=$BUILD_DIR/fontsproto-${FONTSPROTO_VERSION}
FONTSPROTO_ENV=

build_fontsproto() {
    test -e "$STATE_DIR/fontsproto-${FONTSPROTO_VERSION}" && return
    banner "Build $FONTSPROTO"
    download $FONTSPROTO_MIRROR $FONTSPROTO
    extract $FONTSPROTO
    apply_patches $FONTSPROTO_DIR $FONTSPROTO
    pushd $TOP_DIR
    cd $FONTSPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$FONTSPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/fontsproto-${FONTSPROTO_VERSION}"
}

build_fontsproto
