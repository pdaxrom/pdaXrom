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

LIBFONTENC_VERSION=1.0.5
LIBFONTENC=libfontenc-${LIBFONTENC_VERSION}.tar.bz2
LIBFONTENC_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBFONTENC_DIR=$BUILD_DIR/libfontenc-${LIBFONTENC_VERSION}
LIBFONTENC_ENV=

build_libfontenc() {
    test -e "$STATE_DIR/libfontenc-${LIBFONTENC_VERSION}" && return
    banner "Build $LIBFONTENC"
    download $LIBFONTENC_MIRROR $LIBFONTENC
    extract $LIBFONTENC
    apply_patches $LIBFONTENC_DIR $LIBFONTENC
    pushd $TOP_DIR
    cd $LIBFONTENC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBFONTENC_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libfontenc-${LIBFONTENC_VERSION}"
}

build_libfontenc
