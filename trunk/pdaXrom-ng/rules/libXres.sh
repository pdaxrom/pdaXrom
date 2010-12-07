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

LIBXRES_VERSION=1.0.5
LIBXRES=libXres-${LIBXRES_VERSION}.tar.bz2
LIBXRES_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXRES_DIR=$BUILD_DIR/libXres-${LIBXRES_VERSION}
LIBXRES_ENV=

build_libXres() {
    test -e "$STATE_DIR/libXres-${LIBXRES_VERSION}" && return
    banner "Build $LIBXRES"
    download $LIBXRES_MIRROR $LIBXRES
    extract $LIBXRES
    apply_patches $LIBXRES_DIR $LIBXRES
    pushd $TOP_DIR
    cd $LIBXRES_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXRES_ENV \
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
    touch "$STATE_DIR/libXres-${LIBXRES_VERSION}"
}

build_libXres
