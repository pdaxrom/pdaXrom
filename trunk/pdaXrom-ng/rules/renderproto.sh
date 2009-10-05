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

RENDERPROTO_VERSION=0.11
RENDERPROTO=renderproto-${RENDERPROTO_VERSION}.tar.bz2
RENDERPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
RENDERPROTO_DIR=$BUILD_DIR/renderproto-${RENDERPROTO_VERSION}
RENDERPROTO_ENV=

build_renderproto() {
    test -e "$STATE_DIR/renderproto-${RENDERPROTO_VERSION}" && return
    banner "Build $RENDERPROTO"
    download $RENDERPROTO_MIRROR $RENDERPROTO
    extract $RENDERPROTO
    apply_patches $RENDERPROTO_DIR $RENDERPROTO
    pushd $TOP_DIR
    cd $RENDERPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$RENDERPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/renderproto-${RENDERPROTO_VERSION}"
}

build_renderproto
