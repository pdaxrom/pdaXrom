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

LIBXEXT_VERSION=1.2.0
LIBXEXT=libXext-${LIBXEXT_VERSION}.tar.bz2
LIBXEXT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXEXT_DIR=$BUILD_DIR/libXext-${LIBXEXT_VERSION}
LIBXEXT_ENV=

build_libXext() {
    test -e "$STATE_DIR/libXext-${LIBXEXT_VERSION}" && return
    banner "Build $LIBXEXT"
    download $LIBXEXT_MIRROR $LIBXEXT
    extract $LIBXEXT
    apply_patches $LIBXEXT_DIR $LIBXEXT
    pushd $TOP_DIR
    cd $LIBXEXT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXEXT_ENV \
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
    touch "$STATE_DIR/libXext-${LIBXEXT_VERSION}"
}

build_libXext
