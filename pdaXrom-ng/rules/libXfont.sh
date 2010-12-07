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

LIBXFONT_VERSION=1.4.3
LIBXFONT=libXfont-${LIBXFONT_VERSION}.tar.bz2
LIBXFONT_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXFONT_DIR=$BUILD_DIR/libXfont-${LIBXFONT_VERSION}
LIBXFONT_ENV=

build_libXfont() {
    test -e "$STATE_DIR/libXfont-${LIBXFONT_VERSION}" && return
    banner "Build $LIBXFONT"
    download $LIBXFONT_MIRROR $LIBXFONT
    extract $LIBXFONT
    apply_patches $LIBXFONT_DIR $LIBXFONT
    pushd $TOP_DIR
    cd $LIBXFONT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXFONT_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-freetype \
	    --enable-fc \
	    --enable-fontcache \
	    --enable-type1 \
	    --enable-cid \
	    --enable-speedo \
	    --enable-pcfformat \
	    --enable-bdfformat \
	    --enable-snfformat \
	    --enable-builtins \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXfont-${LIBXFONT_VERSION}"
}

build_libXfont
