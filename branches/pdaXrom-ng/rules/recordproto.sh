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

RECORDPROTO=recordproto-1.13.2.tar.bz2
RECORDPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/X11R7.3/src/proto
RECORDPROTO_DIR=$BUILD_DIR/recordproto-1.13.2
RECORDPROTO_ENV=

build_recordproto() {
    test -e "$STATE_DIR/recordproto-1.13.2" && return
    banner "Build $RECORDPROTO"
    download $RECORDPROTO_MIRROR $RECORDPROTO
    extract $RECORDPROTO
    apply_patches $RECORDPROTO_DIR $RECORDPROTO
    pushd $TOP_DIR
    cd $RECORDPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$RECORDPROTO_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/recordproto-1.13.2"
}

build_recordproto
