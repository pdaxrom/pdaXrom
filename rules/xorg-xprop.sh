#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

XORG_XPROP_VERSION=1.1.0
XORG_XPROP=xprop-${XORG_XPROP_VERSION}.tar.bz2
XORG_XPROP_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XPROP_DIR=$BUILD_DIR/xprop-${XORG_XPROP_VERSION}
XORG_XPROP_ENV="$CROSS_ENV_AC"

build_xorg_xprop() {
    test -e "$STATE_DIR/xorg_xprop.installed" && return
    banner "Build xorg-xprop"
    download $XORG_XPROP_MIRROR $XORG_XPROP
    extract $XORG_XPROP
    apply_patches $XORG_XPROP_DIR $XORG_XPROP
    pushd $TOP_DIR
    cd $XORG_XPROP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XPROP_ENV \
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
    touch "$STATE_DIR/xorg_xprop.installed"
}

build_xorg_xprop
