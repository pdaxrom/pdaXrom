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

PRINTPROTO_VERSION=1.0.4
PRINTPROTO=printproto-${PRINTPROTO_VERSION}.tar.bz2
PRINTPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
PRINTPROTO_DIR=$BUILD_DIR/printproto-${PRINTPROTO_VERSION}
PRINTPROTO_ENV=

build_printproto() {
    test -e "$STATE_DIR/printproto-${PRINTPROTO_VERSION}" && return
    banner "Build $PRINTPROTO"
    download $PRINTPROTO_MIRROR $PRINTPROTO
    extract $PRINTPROTO
    apply_patches $PRINTPROTO_DIR $PRINTPROTO
    pushd $TOP_DIR
    cd $PRINTPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$PRINTPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/printproto-${PRINTPROTO_VERSION}"
}

build_printproto
