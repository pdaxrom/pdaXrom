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

SCRNSAVERPROTO=scrnsaverproto-1.1.0.tar.bz2
SCRNSAVERPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/proto
SCRNSAVERPROTO_DIR=$BUILD_DIR/scrnsaverproto-1.1.0
SCRNSAVERPROTO_ENV=

build_scrnsaverproto() {
    test -e "$STATE_DIR/scrnsaverproto-1.1.0" && return
    banner "Build $SCRNSAVERPROTO"
    download $SCRNSAVERPROTO_MIRROR $SCRNSAVERPROTO
    extract $SCRNSAVERPROTO
    apply_patches $SCRNSAVERPROTO_DIR $SCRNSAVERPROTO
    pushd $TOP_DIR
    cd $SCRNSAVERPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SCRNSAVERPROTO_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/scrnsaverproto-1.1.0"
}

build_scrnsaverproto
