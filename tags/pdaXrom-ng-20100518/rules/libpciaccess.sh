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

LIBPCIACCESS_VERSION=0.10.9
LIBPCIACCESS=libpciaccess-${LIBPCIACCESS_VERSION}.tar.bz2
LIBPCIACCESS_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBPCIACCESS_DIR=$BUILD_DIR/libpciaccess-${LIBPCIACCESS_VERSION}
LIBPCIACCESS_ENV=

build_libpciaccess() {
    test -e "$STATE_DIR/libpciaccess-${LIBPCIACCESS_VERSION}" && return
    banner "Build $LIBPCIACCESS"
    download $LIBPCIACCESS_MIRROR $LIBPCIACCESS
    extract $LIBPCIACCESS
    apply_patches $LIBPCIACCESS_DIR $LIBPCIACCESS
    pushd $TOP_DIR
    cd $LIBPCIACCESS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBPCIACCESS_ENV \
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
    touch "$STATE_DIR/libpciaccess-${LIBPCIACCESS_VERSION}"
}

build_libpciaccess
