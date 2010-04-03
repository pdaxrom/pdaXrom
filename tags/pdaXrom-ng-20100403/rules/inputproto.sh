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

INPUTPROTO_VERSION=1.5.0
INPUTPROTO=inputproto-${INPUTPROTO_VERSION}.tar.bz2
INPUTPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
INPUTPROTO_DIR=$BUILD_DIR/inputproto-${INPUTPROTO_VERSION}
INPUTPROTO_ENV=

build_inputproto() {
    test -e "$STATE_DIR/inputproto-${INPUTPROTO_VERSION}" && return
    banner "Build $INPUTPROTO"
    download $INPUTPROTO_MIRROR $INPUTPROTO
    extract $INPUTPROTO
    apply_patches $INPUTPROTO_DIR $INPUTPROTO
    pushd $TOP_DIR
    cd $INPUTPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$INPUTPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/inputproto-${INPUTPROTO_VERSION}"
}

build_inputproto
