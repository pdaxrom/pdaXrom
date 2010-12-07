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

LIBXT_VERSION=1.0.9
LIBXT=libXt-${LIBXT_VERSION}.tar.bz2
LIBXT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXT_DIR=$BUILD_DIR/libXt-${LIBXT_VERSION}
LIBXT_ENV=

build_libXt() {
    test -e "$STATE_DIR/libXt-${LIBXT_VERSION}" && return
    banner "Build $LIBXT"
    download $LIBXT_MIRROR $LIBXT
    extract $LIBXT
    apply_patches $LIBXT_DIR $LIBXT
    pushd $TOP_DIR
    cd $LIBXT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    --disable-install-makestrs \
	    --enable-xkb \
	    || error
    )
    make -C util $MAKEARGS || error
    
    $HOST_CC -I$TARGET_INC util/makestrs.c -o util/makestrs || error "makestrs"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXt-${LIBXT_VERSION}"
}

build_libXt
