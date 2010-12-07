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

DAMAGEPROTO_VERSION=1.2.1
DAMAGEPROTO=damageproto-${DAMAGEPROTO_VERSION}.tar.bz2
DAMAGEPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
DAMAGEPROTO_DIR=$BUILD_DIR/damageproto-${DAMAGEPROTO_VERSION}
DAMAGEPROTO_ENV=

build_damageproto() {
    test -e "$STATE_DIR/damageproto-${DAMAGEPROTO_VERSION}" && return
    banner "Build $DAMAGEPROTO"
    download $DAMAGEPROTO_MIRROR $DAMAGEPROTO
    extract $DAMAGEPROTO
    apply_patches $DAMAGEPROTO_DIR $DAMAGEPROTO
    pushd $TOP_DIR
    cd $DAMAGEPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$DAMAGEPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/damageproto-${DAMAGEPROTO_VERSION}"
}

build_damageproto
