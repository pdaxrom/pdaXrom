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

XPROTO_VERSION=7.0.19
XPROTO=xproto-${XPROTO_VERSION}.tar.bz2
XPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
XPROTO_DIR=$BUILD_DIR/xproto-${XPROTO_VERSION}
XPROTO_ENV=

build_xproto() {
    test -e "$STATE_DIR/xproto-${XPROTO_VERSION}" && return
    banner "Build $XPROTO"
    download $XPROTO_MIRROR $XPROTO
    extract $XPROTO
    apply_patches $XPROTO_DIR $XPROTO
    pushd $TOP_DIR
    cd $XPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/xproto-${XPROTO_VERSION}"
}

build_xproto
