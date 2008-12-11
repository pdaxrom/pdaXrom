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

FIXESPROTO=fixesproto-4.0.tar.bz2
FIXESPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
FIXESPROTO_DIR=$BUILD_DIR/fixesproto-4.0
FIXESPROTO_ENV=

build_fixesproto() {
    test -e "$STATE_DIR/fixesproto-4.0" && return
    banner "Build $FIXESPROTO"
    download $FIXESPROTO_MIRROR $FIXESPROTO
    extract $FIXESPROTO
    apply_patches $FIXESPROTO_DIR $FIXESPROTO
    pushd $TOP_DIR
    cd $FIXESPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$FIXESPROTO_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files

    popd
    touch "$STATE_DIR/fixesproto-4.0"
}

build_fixesproto
