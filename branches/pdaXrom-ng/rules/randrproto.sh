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

RANDRPROTO_VERSION=1.2.99.4
RANDRPROTO=randrproto-${RANDRPROTO_VERSION}.tar.bz2
RANDRPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
RANDRPROTO_DIR=$BUILD_DIR/randrproto-${RANDRPROTO_VERSION}
RANDRPROTO_ENV=

build_randrproto() {
    test -e "$STATE_DIR/randrproto-${RANDRPROTO_VERSION}" && return
    banner "Build $RANDRPROTO"
    download $RANDRPROTO_MIRROR $RANDRPROTO
    extract $RANDRPROTO
    apply_patches $RANDRPROTO_DIR $RANDRPROTO
    pushd $TOP_DIR
    cd $RANDRPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$RANDRPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/randrproto-${RANDRPROTO_VERSION}"
}

build_randrproto
