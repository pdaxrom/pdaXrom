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

PRINTPROTO=printproto-1.0.3.tar.bz2
PRINTPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/proto
PRINTPROTO_DIR=$BUILD_DIR/printproto-1.0.3
PRINTPROTO_ENV=

build_printproto() {
    test -e "$STATE_DIR/printproto-1.0.3" && return
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
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/printproto-1.0.3"
}

build_printproto
