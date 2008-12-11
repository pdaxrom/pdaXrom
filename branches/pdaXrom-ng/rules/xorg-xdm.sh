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

XORG_XDM=xdm-1.1.8.tar.bz2
XORG_XDM_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/app
XORG_XDM_DIR=$BUILD_DIR/xdm-1.1.8
XORG_XDM_ENV=

build_xorg_xdm() {
    test -e "$STATE_DIR/xorg_xdm-1.1.8" && return
    banner "Build $XORG_XDM"
    download $XORG_XDM_MIRROR $XORG_XDM
    extract $XORG_XDM
    apply_patches $XORG_XDM_DIR $XORG_XDM
    pushd $TOP_DIR
    cd $XORG_XDM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XORG_XDM_ENV \
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --datadir=/usr/share \
	    --with-random-device=/dev/urandom \
	    --disable-secure-rpc \
	    --enable-xpm-logos \
	    --disable-xprint \
	    --enable-dynamic-greeter \
	    --without-pam \
	    --disable-static \
	    || error
    )
    make $MAKEARGS || error

    error "update install"

    popd
    touch "$STATE_DIR/xorg_xdm-1.1.8"
}

build_xorg_xdm
