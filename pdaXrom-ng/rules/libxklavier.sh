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

LIBXKLAVIER_VERSION=5.0
LIBXKLAVIER=libxklavier-${LIBXKLAVIER_VERSION}.tar.bz2
LIBXKLAVIER_MIRROR=http://ftp.acc.umu.se/pub/gnome/sources/libxklavier/5.0
LIBXKLAVIER_DIR=$BUILD_DIR/libxklavier-${LIBXKLAVIER_VERSION}
LIBXKLAVIER_ENV="$CROSS_ENV_AC"

build_libxklavier() {
    test -e "$STATE_DIR/libxklavier.installed" && return
    banner "Build libxklavier"
    download $LIBXKLAVIER_MIRROR $LIBXKLAVIER
    extract $LIBXKLAVIER
    apply_patches $LIBXKLAVIER_DIR $LIBXKLAVIER
    pushd $TOP_DIR
    cd $LIBXKLAVIER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXKLAVIER_ENV \
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
    touch "$STATE_DIR/libxklavier.installed"
}

build_libxklavier
