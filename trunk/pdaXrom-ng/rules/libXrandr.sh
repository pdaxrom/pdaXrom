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

LIBXRANDR_VERSION=1.3.1
LIBXRANDR=libXrandr-${LIBXRANDR_VERSION}.tar.bz2
LIBXRANDR_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXRANDR_DIR=$BUILD_DIR/libXrandr-${LIBXRANDR_VERSION}
LIBXRANDR_ENV=

build_libXrandr() {
    test -e "$STATE_DIR/libXrandr-${LIBXRANDR_VERSION}" && return
    banner "Build $LIBXRANDR"
    download $LIBXRANDR_MIRROR $LIBXRANDR
    extract $LIBXRANDR
    apply_patches $LIBXRANDR_DIR $LIBXRANDR
    pushd $TOP_DIR
    cd $LIBXRANDR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXRANDR_ENV \
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
    touch "$STATE_DIR/libXrandr-${LIBXRANDR_VERSION}"
}

build_libXrandr
