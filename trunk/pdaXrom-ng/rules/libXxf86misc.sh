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

LIBXXF86MISC_VERSION=1.0.3
LIBXXF86MISC=libXxf86misc-${LIBXXF86MISC_VERSION}.tar.bz2
LIBXXF86MISC_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXXF86MISC_DIR=$BUILD_DIR/libXxf86misc-${LIBXXF86MISC_VERSION}
LIBXXF86MISC_ENV=

build_libXxf86misc() {
    test -e "$STATE_DIR/libXxf86misc-${LIBXXF86MISC_VERSION}" && return
    banner "Build $LIBXXF86MISC"
    download $LIBXXF86MISC_MIRROR $LIBXXF86MISC
    extract $LIBXXF86MISC
    apply_patches $LIBXXF86MISC_DIR $LIBXXF86MISC
    pushd $TOP_DIR
    cd $LIBXXF86MISC_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXXF86MISC_ENV \
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
    touch "$STATE_DIR/libXxf86misc-${LIBXXF86MISC_VERSION}"
}

build_libXxf86misc
