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

COMPOSITEPROTO_VERSION=0.4.2
COMPOSITEPROTO=compositeproto-${COMPOSITEPROTO_VERSION}.tar.bz2
COMPOSITEPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
COMPOSITEPROTO_DIR=$BUILD_DIR/compositeproto-${COMPOSITEPROTO_VERSION}
COMPOSITEPROTO_ENV=

build_compositeproto() {
    test -e "$STATE_DIR/compositeproto-${COMPOSITEPROTO_VERSION}" && return
    banner "Build $COMPOSITEPROTO"
    download $COMPOSITEPROTO_MIRROR $COMPOSITEPROTO
    extract $COMPOSITEPROTO
    apply_patches $COMPOSITEPROTO_DIR $COMPOSITEPROTO
    pushd $TOP_DIR
    cd $COMPOSITEPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$COMPOSITEPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/compositeproto-${COMPOSITEPROTO_VERSION}"
}

build_compositeproto
