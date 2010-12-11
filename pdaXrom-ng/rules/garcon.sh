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

GARCON_VERSION=0.1.4
GARCON=garcon-${GARCON_VERSION}.tar.bz2
GARCON_MIRROR=http://ftp.uni-erlangen.de/pub/mirrors/gentoo/distfiles
GARCON_DIR=$BUILD_DIR/garcon-${GARCON_VERSION}
GARCON_ENV="$CROSS_ENV_AC"

build_garcon() {
    test -e "$STATE_DIR/garcon.installed" && return
    banner "Build garcon"
    download $GARCON_MIRROR $GARCON
    extract $GARCON
    apply_patches $GARCON_DIR $GARCON
    pushd $TOP_DIR
    cd $GARCON_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GARCON_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/garcon.installed"
}

build_garcon
