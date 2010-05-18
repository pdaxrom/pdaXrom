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

LIBXPM_VERSION=3.5.7
LIBXPM=libXpm-${LIBXPM_VERSION}.tar.bz2
LIBXPM_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXPM_DIR=$BUILD_DIR/libXpm-${LIBXPM_VERSION}
LIBXPM_ENV=

build_libXpm() {
    test -e "$STATE_DIR/libXpm-${LIBXPM_VERSION}" && return
    banner "Build $LIBXPM"
    download $LIBXPM_MIRROR $LIBXPM
    extract $LIBXPM
    apply_patches $LIBXPM_DIR $LIBXPM
    pushd $TOP_DIR
    cd $LIBXPM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXPM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXpm-${LIBXPM_VERSION}"
}

build_libXpm
