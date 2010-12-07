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

LIBXEVIE_VERSION=1.0.3
LIBXEVIE=libXevie-${LIBXEVIE_VERSION}.tar.bz2
LIBXEVIE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXEVIE_DIR=$BUILD_DIR/libXevie-${LIBXEVIE_VERSION}
LIBXEVIE_ENV=

build_libXevie() {
    test -e "$STATE_DIR/libXevie-${LIBXEVIE_VERSION}" && return
    banner "Build $LIBXEVIE"
    download $LIBXEVIE_MIRROR $LIBXEVIE
    extract $LIBXEVIE
    apply_patches $LIBXEVIE_DIR $LIBXEVIE
    pushd $TOP_DIR
    cd $LIBXEVIE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXEVIE_ENV \
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
    touch "$STATE_DIR/libXevie-${LIBXEVIE_VERSION}"
}

build_libXevie
