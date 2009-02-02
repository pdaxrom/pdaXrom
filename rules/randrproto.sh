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

RANDRPROTO=randrproto-1.2.2.tar.bz2
RANDRPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
RANDRPROTO_DIR=$BUILD_DIR/randrproto-1.2.2
RANDRPROTO_ENV=

build_randrproto() {
    test -e "$STATE_DIR/randrproto-1.2.1" && return
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
    touch "$STATE_DIR/randrproto-1.2.1"
}

build_randrproto
