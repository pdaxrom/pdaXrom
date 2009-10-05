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

LIBXTRAP_VERSION=1.0.0
LIBXTRAP=libXTrap-${LIBXTRAP_VERSION}.tar.bz2
LIBXTRAP_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXTRAP_DIR=$BUILD_DIR/libXTrap-${LIBXTRAP_VERSION}
LIBXTRAP_ENV=

build_libXTrap() {
    test -e "$STATE_DIR/libXTrap-${LIBXTRAP_VERSION}" && return
    banner "Build $LIBXTRAP"
    download $LIBXTRAP_MIRROR $LIBXTRAP
    extract $LIBXTRAP
    apply_patches $LIBXTRAP_DIR $LIBXTRAP
    pushd $TOP_DIR
    cd $LIBXTRAP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXTRAP_ENV \
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
    touch "$STATE_DIR/libXTrap-${LIBXTRAP_VERSION}"
}

build_libXTrap
