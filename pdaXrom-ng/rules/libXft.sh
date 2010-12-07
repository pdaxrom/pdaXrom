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

LIBXFT_VERSION=2.2.0
LIBXFT=libXft-${LIBXFT_VERSION}.tar.bz2
LIBXFT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXFT_DIR=$BUILD_DIR/libXft-${LIBXFT_VERSION}
LIBXFT_ENV=

build_libXft() {
    test -e "$STATE_DIR/libXft-${LIBXFT_VERSION}" && return
    banner "Build $LIBXFT"
    download $LIBXFT_MIRROR $LIBXFT
    extract $LIBXFT
    apply_patches $LIBXFT_DIR $LIBXFT
    pushd $TOP_DIR
    cd $LIBXFT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXFT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    ln -sf $TARGET_BIN_DIR/bin/xft-config $HOST_BIN_DIR/bin/ || error

    popd
    touch "$STATE_DIR/libXft-${LIBXFT_VERSION}"
}

build_libXft
