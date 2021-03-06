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

XINERAMAPROTO_VERSION=1.2
XINERAMAPROTO=xineramaproto-${XINERAMAPROTO_VERSION}.tar.bz2
XINERAMAPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
XINERAMAPROTO_DIR=$BUILD_DIR/xineramaproto-${XINERAMAPROTO_VERSION}
XINERAMAPROTO_ENV=

build_xineramaproto() {
    test -e "$STATE_DIR/xineramaproto-${XINERAMAPROTO_VERSION}" && return
    banner "Build $XINERAMAPROTO"
    download $XINERAMAPROTO_MIRROR $XINERAMAPROTO
    extract $XINERAMAPROTO
    apply_patches $XINERAMAPROTO_DIR $XINERAMAPROTO
    pushd $TOP_DIR
    cd $XINERAMAPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XINERAMAPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/xineramaproto-${XINERAMAPROTO_VERSION}"
}

build_xineramaproto
