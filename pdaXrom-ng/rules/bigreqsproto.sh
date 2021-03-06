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

BIGREQSPROTO_VERSION=1.1.1
BIGREQSPROTO=bigreqsproto-${BIGREQSPROTO_VERSION}.tar.bz2
BIGREQSPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
BIGREQSPROTO_DIR=$BUILD_DIR/bigreqsproto-${BIGREQSPROTO_VERSION}
BIGREQSPROTO_ENV=

build_bigreqsproto() {
    test -e "$STATE_DIR/bigreqsproto-${BIGREQSPROTO_VERSION}" && return
    banner "Build $BIGREQSPROTO"
    download $BIGREQSPROTO_MIRROR $BIGREQSPROTO
    extract $BIGREQSPROTO
    apply_patches $BIGREQSPROTO_DIR $BIGREQSPROTO
    pushd $TOP_DIR
    cd $BIGREQSPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$BIGREQSPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/bigreqsproto-${BIGREQSPROTO_VERSION}"
}

build_bigreqsproto
