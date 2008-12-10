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

RENDERPROTO=renderproto-0.9.3.tar.bz2
RENDERPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/proto
RENDERPROTO_DIR=$BUILD_DIR/renderproto-0.9.3
RENDERPROTO_ENV=

build_renderproto() {
    test -e "$STATE_DIR/renderproto-0.9.3" && return
    banner "Build $RENDERPROTO"
    download $RENDERPROTO_MIRROR $RENDERPROTO
    extract $RENDERPROTO
    apply_patches $RENDERPROTO_DIR $RENDERPROTO
    pushd $TOP_DIR
    cd $RENDERPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$RENDERPROTO_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/renderproto-0.9.3"
}

build_renderproto
