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

LIBXTST_VERSION=1.2.0
LIBXTST=libXtst-${LIBXTST_VERSION}.tar.bz2
LIBXTST_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXTST_DIR=$BUILD_DIR/libXtst-${LIBXTST_VERSION}
LIBXTST_ENV=

build_libXtst() {
    test -e "$STATE_DIR/libXtst-${LIBXTST_VERSION}" && return
    banner "Build $LIBXTST"
    download $LIBXTST_MIRROR $LIBXTST
    extract $LIBXTST
    apply_patches $LIBXTST_DIR $LIBXTST
    pushd $TOP_DIR
    cd $LIBXTST_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXTST_ENV \
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
    touch "$STATE_DIR/libXtst-${LIBXTST_VERSION}"
}

build_libXtst
