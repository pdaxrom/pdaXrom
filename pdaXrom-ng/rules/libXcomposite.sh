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

LIBXCOMPOSITE_VERSION=0.4.3
LIBXCOMPOSITE=libXcomposite-${LIBXCOMPOSITE_VERSION}.tar.bz2
LIBXCOMPOSITE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXCOMPOSITE_DIR=$BUILD_DIR/libXcomposite-${LIBXCOMPOSITE_VERSION}
LIBXCOMPOSITE_ENV=

build_libXcomposite() {
    test -e "$STATE_DIR/libXcomposite-${LIBXCOMPOSITE_VERSION}" && return
    banner "Build $LIBXCOMPOSITE"
    download $LIBXCOMPOSITE_MIRROR $LIBXCOMPOSITE
    extract $LIBXCOMPOSITE
    apply_patches $LIBXCOMPOSITE_DIR $LIBXCOMPOSITE
    pushd $TOP_DIR
    cd $LIBXCOMPOSITE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXCOMPOSITE_ENV \
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
    touch "$STATE_DIR/libXcomposite-${LIBXCOMPOSITE_VERSION}"
}

build_libXcomposite
