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

LIBSM_VERSION=1.1.1
LIBSM=libSM-${LIBSM_VERSION}.tar.bz2
LIBSM_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBSM_DIR=$BUILD_DIR/libSM-${LIBSM_VERSION}
LIBSM_ENV=

build_libSM() {
    test -e "$STATE_DIR/libSM-${LIBSM_VERSION}" && return
    banner "Build $LIBSM"
    download $LIBSM_MIRROR $LIBSM
    extract $LIBSM
    apply_patches $LIBSM_DIR $LIBSM
    pushd $TOP_DIR
    cd $LIBSM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBSM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libSM-${LIBSM_VERSION}"
}

build_libSM
