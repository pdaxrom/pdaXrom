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

LIBXFIXES_VERSION=4.0.3
LIBXFIXES=libXfixes-${LIBXFIXES_VERSION}.tar.bz2
LIBXFIXES_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXFIXES_DIR=$BUILD_DIR/libXfixes-${LIBXFIXES_VERSION}
LIBXFIXES_ENV=

build_libXfixes() {
    test -e "$STATE_DIR/libXfixes-${LIBXFIXES_VERSION}" && return
    banner "Build $LIBXFIXES"
    download $LIBXFIXES_MIRROR $LIBXFIXES
    extract $LIBXFIXES
    apply_patches $LIBXFIXES_DIR $LIBXFIXES
    pushd $TOP_DIR
    cd $LIBXFIXES_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXFIXES_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXfixes-${LIBXFIXES_VERSION}"
}

build_libXfixes
