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

LIBXINERAMA_VERSION=1.0.3
LIBXINERAMA=libXinerama-${LIBXINERAMA_VERSION}.tar.bz2
LIBXINERAMA_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXINERAMA_DIR=$BUILD_DIR/libXinerama-${LIBXINERAMA_VERSION}
LIBXINERAMA_ENV=

build_libXinerama() {
    test -e "$STATE_DIR/libXinerama-${LIBXINERAMA_VERSION}" && return
    banner "Build $LIBXINERAMA"
    download $LIBXINERAMA_MIRROR $LIBXINERAMA
    extract $LIBXINERAMA
    apply_patches $LIBXINERAMA_DIR $LIBXINERAMA
    pushd $TOP_DIR
    cd $LIBXINERAMA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXINERAMA_ENV \
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
    touch "$STATE_DIR/libXinerama-${LIBXINERAMA_VERSION}"
}

build_libXinerama
