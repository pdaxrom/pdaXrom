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

XEXTPROTO=xextproto-7.0.3.tar.bz2
XEXTPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
XEXTPROTO_DIR=$BUILD_DIR/xextproto-7.0.3
XEXTPROTO_ENV=

build_xextproto() {
    test -e "$STATE_DIR/xextproto-7.0.2" && return
    banner "Build $XEXTPROTO"
    download $XEXTPROTO_MIRROR $XEXTPROTO
    extract $XEXTPROTO
    apply_patches $XEXTPROTO_DIR $XEXTPROTO
    pushd $TOP_DIR
    cd $XEXTPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XEXTPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/xextproto-7.0.2"
}

build_xextproto