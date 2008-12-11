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

XCMISCPROTO=xcmiscproto-1.1.2.tar.bz2
XCMISCPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
XCMISCPROTO_DIR=$BUILD_DIR/xcmiscproto-1.1.2
XCMISCPROTO_ENV=

build_xcmiscproto() {
    test -e "$STATE_DIR/xcmiscproto-1.1.2" && return
    banner "Build $XCMISCPROTO"
    download $XCMISCPROTO_MIRROR $XCMISCPROTO
    extract $XCMISCPROTO
    apply_patches $XCMISCPROTO_DIR $XCMISCPROTO
    pushd $TOP_DIR
    cd $XCMISCPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XCMISCPROTO_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/xcmiscproto-1.1.2"
}

build_xcmiscproto
