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

RESOURCEPROTO_VERSION=1.1.0
RESOURCEPROTO=resourceproto-${RESOURCEPROTO_VERSION}.tar.bz2
RESOURCEPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
RESOURCEPROTO_DIR=$BUILD_DIR/resourceproto-${RESOURCEPROTO_VERSION}
RESOURCEPROTO_ENV=

build_resourceproto() {
    test -e "$STATE_DIR/resourceproto-${RESOURCEPROTO_VERSION}" && return
    banner "Build $RESOURCEPROTO"
    download $RESOURCEPROTO_MIRROR $RESOURCEPROTO
    extract $RESOURCEPROTO
    apply_patches $RESOURCEPROTO_DIR $RESOURCEPROTO
    pushd $TOP_DIR
    cd $RESOURCEPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$RESOURCEPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/resourceproto-${RESOURCEPROTO_VERSION}"
}

build_resourceproto
