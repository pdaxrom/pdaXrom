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

LIBXSCRNSAVER_VERSION=1.2.0
LIBXSCRNSAVER=libXScrnSaver-${LIBXSCRNSAVER_VERSION}.tar.bz2
LIBXSCRNSAVER_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXSCRNSAVER_DIR=$BUILD_DIR/libXScrnSaver-${LIBXSCRNSAVER_VERSION}
LIBXSCRNSAVER_ENV=

build_libXScrnSaver() {
    test -e "$STATE_DIR/libXScrnSaver-${LIBXSCRNSAVER_VERSION}" && return
    banner "Build $LIBXSCRNSAVER"
    download $LIBXSCRNSAVER_MIRROR $LIBXSCRNSAVER
    extract $LIBXSCRNSAVER
    apply_patches $LIBXSCRNSAVER_DIR $LIBXSCRNSAVER
    pushd $TOP_DIR
    cd $LIBXSCRNSAVER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXSCRNSAVER_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXScrnSaver-${LIBXSCRNSAVER_VERSION}"
}

build_libXScrnSaver
