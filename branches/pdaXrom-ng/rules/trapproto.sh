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

TRAPPROTO=trapproto-3.4.3.tar.bz2
TRAPPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/proto
TRAPPROTO_DIR=$BUILD_DIR/trapproto-3.4.3
TRAPPROTO_ENV=

build_trapproto() {
    test -e "$STATE_DIR/trapproto-3.4.3" && return
    banner "Build $TRAPPROTO"
    download $TRAPPROTO_MIRROR $TRAPPROTO
    extract $TRAPPROTO
    apply_patches $TRAPPROTO_DIR $TRAPPROTO
    pushd $TOP_DIR
    cd $TRAPPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TRAPPROTO_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/trapproto-3.4.3"
}

build_trapproto
