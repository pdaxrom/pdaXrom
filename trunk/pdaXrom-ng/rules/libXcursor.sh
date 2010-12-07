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

LIBXCURSOR_VERSION=1.1.11
LIBXCURSOR=libXcursor-${LIBXCURSOR_VERSION}.tar.bz2
LIBXCURSOR_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXCURSOR_DIR=$BUILD_DIR/libXcursor-${LIBXCURSOR_VERSION}
LIBXCURSOR_ENV=

build_libXcursor() {
    test -e "$STATE_DIR/libXcursor-${LIBXCURSOR_VERSION}" && return
    banner "Build $LIBXCURSOR"
    download $LIBXCURSOR_MIRROR $LIBXCURSOR
    extract $LIBXCURSOR
    apply_patches $LIBXCURSOR_DIR $LIBXCURSOR
    pushd $TOP_DIR
    cd $LIBXCURSOR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXCURSOR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXcursor-${LIBXCURSOR_VERSION}"
}

build_libXcursor
