#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

DMXPROTO_VERSION=2.3
DMXPROTO=dmxproto-${DMXPROTO_VERSION}.tar.bz2
DMXPROTO_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/proto
DMXPROTO_DIR=$BUILD_DIR/dmxproto-${DMXPROTO_VERSION}
DMXPROTO_ENV="$CROSS_ENV_AC"

build_dmxproto() {
    test -e "$STATE_DIR/dmxproto.installed" && return
    banner "Build dmxproto"
    download $DMXPROTO_MIRROR $DMXPROTO
    extract $DMXPROTO
    apply_patches $DMXPROTO_DIR $DMXPROTO
    pushd $TOP_DIR
    cd $DMXPROTO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$DMXPROTO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/dmxproto.installed"
}

build_dmxproto
