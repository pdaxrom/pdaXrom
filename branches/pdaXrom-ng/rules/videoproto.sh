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

VIDEOPROTO=videoproto-2.2.2.tar.bz2
VIDEOPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
VIDEOPROTO_DIR=$BUILD_DIR/videoproto-2.2.2
VIDEOPROTO_ENV=

build_videoproto() {
    test -e "$STATE_DIR/videoproto-2.2.2" && return
    banner "Build $VIDEOPROTO"
    download $VIDEOPROTO_MIRROR $VIDEOPROTO
    extract $VIDEOPROTO
    apply_patches $VIDEOPROTO_DIR $VIDEOPROTO
    pushd $TOP_DIR
    cd $VIDEOPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$VIDEOPROTO_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/videoproto-2.2.2"
}

build_videoproto
