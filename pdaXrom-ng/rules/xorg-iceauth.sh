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

XORG_ICEAUTH_VERSION=1.0.4
XORG_ICEAUTH=iceauth-${XORG_ICEAUTH_VERSION}.tar.bz2
XORG_ICEAUTH_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_ICEAUTH_DIR=$BUILD_DIR/iceauth-${XORG_ICEAUTH_VERSION}
XORG_ICEAUTH_ENV="$CROSS_ENV_AC"

build_xorg_iceauth() {
    test -e "$STATE_DIR/xorg_iceauth.installed" && return
    banner "Build xorg-iceauth"
    download $XORG_ICEAUTH_MIRROR $XORG_ICEAUTH
    extract $XORG_ICEAUTH
    apply_patches $XORG_ICEAUTH_DIR $XORG_ICEAUTH
    pushd $TOP_DIR
    cd $XORG_ICEAUTH_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_ICEAUTH_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/xorg_iceauth.installed"
}

build_xorg_iceauth
