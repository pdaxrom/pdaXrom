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

LIBICE_VERSION=1.0.6
LIBICE=libICE-${LIBICE_VERSION}.tar.bz2
LIBICE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBICE_DIR=$BUILD_DIR/libICE-${LIBICE_VERSION}
LIBICE_ENV=

build_libICE() {
    test -e "$STATE_DIR/libICE-${LIBICE_VERSION}" && return
    banner "Build $LIBICE"
    download $LIBICE_MIRROR $LIBICE
    extract $LIBICE
    apply_patches $LIBICE_DIR $LIBICE
    pushd $TOP_DIR
    cd $LIBICE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBICE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libICE-${LIBICE_VERSION}"
}

build_libICE
