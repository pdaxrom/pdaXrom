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

LIBXAW_VERSION=1.0.8
LIBXAW=libXaw-${LIBXAW_VERSION}.tar.bz2
LIBXAW_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXAW_DIR=$BUILD_DIR/libXaw-${LIBXAW_VERSION}
LIBXAW_ENV=

build_libXaw() {
    test -e "$STATE_DIR/libXaw-${LIBXAW_VERSION}" && return
    banner "Build $LIBXAW"
    download $LIBXAW_MIRROR $LIBXAW
    extract $LIBXAW
    apply_patches $LIBXAW_DIR $LIBXAW
    pushd $TOP_DIR
    cd $LIBXAW_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXAW_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-xaw6 \
	    --enable-xaw7 \
	    --disable-xaw8 \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXaw-${LIBXAW_VERSION}"
}

build_libXaw
