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

LIBXRENDER_VERSION=0.9.5
LIBXRENDER=libXrender-${LIBXRENDER_VERSION}.tar.bz2
LIBXRENDER_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXRENDER_DIR=$BUILD_DIR/libXrender-${LIBXRENDER_VERSION}
LIBXRENDER_ENV=

build_libXrender() {
    test -e "$STATE_DIR/libXrender-${LIBXRENDER_VERSION}" && return
    banner "Build $LIBXRENDER"
    download $LIBXRENDER_MIRROR $LIBXRENDER
    extract $LIBXRENDER
    apply_patches $LIBXRENDER_DIR $LIBXRENDER
    pushd $TOP_DIR
    cd $LIBXRENDER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXRENDER_ENV \
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
    touch "$STATE_DIR/libXrender-${LIBXRENDER_VERSION}"
}

build_libXrender
