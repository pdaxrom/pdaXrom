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

LIBXV_VERSION=1.0.6
LIBXV=libXv-${LIBXV_VERSION}.tar.bz2
LIBXV_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXV_DIR=$BUILD_DIR/libXv-${LIBXV_VERSION}
LIBXV_ENV=

build_libXv() {
    test -e "$STATE_DIR/libXv-${LIBXV_VERSION}" && return
    banner "Build $LIBXV"
    download $LIBXV_MIRROR $LIBXV
    extract $LIBXV
    apply_patches $LIBXV_DIR $LIBXV
    pushd $TOP_DIR
    cd $LIBXV_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXV_ENV \
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
    touch "$STATE_DIR/libXv-${LIBXV_VERSION}"
}

build_libXv
