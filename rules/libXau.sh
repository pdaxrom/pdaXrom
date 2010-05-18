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

LIBXAU_VERSION=1.0.5
LIBXAU=libXau-${LIBXAU_VERSION}.tar.bz2
LIBXAU_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXAU_DIR=$BUILD_DIR/libXau-${LIBXAU_VERSION}
LIBXAU_ENV=

build_libXau() {
    test -e "$STATE_DIR/libXau-${LIBXAU_VERSION}" && return
    banner "Build $LIBXAU"
    download $LIBXAU_MIRROR $LIBXAU
    extract $LIBXAU
    apply_patches $LIBXAU_DIR $LIBXAU
    pushd $TOP_DIR
    cd $LIBXAU_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXAU_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXau-${LIBXAU_VERSION}"
}

build_libXau
