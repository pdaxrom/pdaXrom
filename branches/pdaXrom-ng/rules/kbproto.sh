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

KBPROTO=kbproto-1.0.3.tar.bz2
KBPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
KBPROTO_DIR=$BUILD_DIR/kbproto-1.0.3
KBPROTO_ENV=

build_kbproto() {
    test -e "$STATE_DIR/kbproto-1.0.3" && return
    banner "Build $KBPROTO"
    download $KBPROTO_MIRROR $KBPROTO
    extract $KBPROTO
    apply_patches $KBPROTO_DIR $KBPROTO
    pushd $TOP_DIR
    cd $KBPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$KBPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/kbproto-1.0.3"
}

build_kbproto
