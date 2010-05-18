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

LIBXFONTCACHE_VERSION=1.0.4
LIBXFONTCACHE=libXfontcache-${LIBXFONTCACHE_VERSION}.tar.bz2
LIBXFONTCACHE_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXFONTCACHE_DIR=$BUILD_DIR/libXfontcache-${LIBXFONTCACHE_VERSION}
LIBXFONTCACHE_ENV=

build_libXfontcache() {
    test -e "$STATE_DIR/libXfontcache-${LIBXFONTCACHE_VERSION}" && return
    banner "Build $LIBXFONTCACHE"
    download $LIBXFONTCACHE_MIRROR $LIBXFONTCACHE
    extract $LIBXFONTCACHE
    apply_patches $LIBXFONTCACHE_DIR $LIBXFONTCACHE
    pushd $TOP_DIR
    cd $LIBXFONTCACHE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXFONTCACHE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-malloc0returnsnull \
	    --disable-man-pages \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXfontcache-${LIBXFONTCACHE_VERSION}"
}

build_libXfontcache
