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

LIBXDAMAGE_VERSION=1.1.1
LIBXDAMAGE=libXdamage-${LIBXDAMAGE_VERSION}.tar.bz2
LIBXDAMAGE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXDAMAGE_DIR=$BUILD_DIR/libXdamage-${LIBXDAMAGE_VERSION}
LIBXDAMAGE_ENV=

build_libXdamage() {
    test -e "$STATE_DIR/libXdamage-${LIBXDAMAGE_VERSION}" && return
    banner "Build $LIBXDAMAGE"
    download $LIBXDAMAGE_MIRROR $LIBXDAMAGE
    extract $LIBXDAMAGE
    apply_patches $LIBXDAMAGE_DIR $LIBXDAMAGE
    pushd $TOP_DIR
    cd $LIBXDAMAGE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXDAMAGE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXdamage-${LIBXDAMAGE_VERSION}"
}

build_libXdamage
