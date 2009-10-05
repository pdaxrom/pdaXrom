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

XTRANS_VERSION=1.2.4
XTRANS=xtrans-${XTRANS_VERSION}.tar.bz2
XTRANS_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
XTRANS_DIR=$BUILD_DIR/xtrans-${XTRANS_VERSION}
XTRANS_ENV=

build_xtrans() {
    test -e "$STATE_DIR/xtrans-${XTRANS_VERSION}" && return
    banner "Build $XTRANS"
    download $XTRANS_MIRROR $XTRANS
    extract $XTRANS
    apply_patches $XTRANS_DIR $XTRANS
    pushd $TOP_DIR
    cd $XTRANS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XTRANS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files

    popd
    touch "$STATE_DIR/xtrans-${XTRANS_VERSION}"
}

build_xtrans
