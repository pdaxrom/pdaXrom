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

XEXTPROTO_VERSION=7.1.2
XEXTPROTO=xextproto-${XEXTPROTO_VERSION}.tar.bz2
XEXTPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
XEXTPROTO_DIR=$BUILD_DIR/xextproto-${XEXTPROTO_VERSION}
XEXTPROTO_ENV=

build_xextproto() {
    test -e "$STATE_DIR/xextproto-${XEXTPROTO_VERSION}" && return
    banner "Build $XEXTPROTO"
    download $XEXTPROTO_MIRROR $XEXTPROTO
    extract $XEXTPROTO
    apply_patches $XEXTPROTO_DIR $XEXTPROTO
    pushd $TOP_DIR
    cd $XEXTPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XEXTPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/xextproto-${XEXTPROTO_VERSION}"
}

build_xextproto
