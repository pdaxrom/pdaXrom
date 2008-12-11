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

INPUTPROTO=inputproto-1.5.0.tar.bz2
INPUTPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
INPUTPROTO_DIR=$BUILD_DIR/inputproto-1.5.0
INPUTPROTO_ENV=

build_inputproto() {
    test -e "$STATE_DIR/inputproto-1.4.2.1" && return
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
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/inputproto-1.4.2.1"
}

build_inputproto
