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

LIBXVMC_VERSION=1.0.6
LIBXVMC=libXvMC-${LIBXVMC_VERSION}.tar.bz2
LIBXVMC_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXVMC_DIR=$BUILD_DIR/libXvMC-${LIBXVMC_VERSION}
LIBXVMC_ENV=

build_libXvMC() {
    test -e "$STATE_DIR/libXvMC-${LIBXVMC_VERSION}" && return
    banner "Build $LIBXVMC"
    download $LIBXVMC_MIRROR $LIBXVMC
    extract $LIBXVMC
    apply_patches $LIBXVMC_DIR $LIBXVMC
    pushd $TOP_DIR
    cd $LIBXVMC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXVMC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXvMC-${LIBXVMC_VERSION}"
}

build_libXvMC
