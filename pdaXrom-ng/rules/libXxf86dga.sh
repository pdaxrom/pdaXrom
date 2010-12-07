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

LIBXXF86DGA_VERSION=1.1.2
LIBXXF86DGA=libXxf86dga-${LIBXXF86DGA_VERSION}.tar.bz2
LIBXXF86DGA_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXXF86DGA_DIR=$BUILD_DIR/libXxf86dga-${LIBXXF86DGA_VERSION}
LIBXXF86DGA_ENV=

build_libXxf86dga() {
    test -e "$STATE_DIR/libXxf86dga-${LIBXXF86DGA_VERSION}" && return
    banner "Build $LIBXXF86DGA"
    download $LIBXXF86DGA_MIRROR $LIBXXF86DGA
    extract $LIBXXF86DGA
    apply_patches $LIBXXF86DGA_DIR $LIBXXF86DGA
    pushd $TOP_DIR
    cd $LIBXXF86DGA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXXF86DGA_ENV \
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
    touch "$STATE_DIR/libXxf86dga-${LIBXXF86DGA_VERSION}"
}

build_libXxf86dga
