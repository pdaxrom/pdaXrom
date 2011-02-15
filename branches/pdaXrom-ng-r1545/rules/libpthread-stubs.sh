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

LIBPTHREAD_STUBS_VERSION=0.1
LIBPTHREAD_STUBS=libpthread-stubs-${LIBPTHREAD_STUBS_VERSION}.tar.bz2
LIBPTHREAD_STUBS_MIRROR=http://xcb.freedesktop.org/dist
LIBPTHREAD_STUBS_DIR=$BUILD_DIR/libpthread-stubs-${LIBPTHREAD_STUBS_VERSION}
LIBPTHREAD_STUBS_ENV=

build_libpthread_stubs() {
    test -e "$STATE_DIR/libpthread_stubs-${LIBPTHREAD_STUBS_VERSION}" && return
    banner "Build $LIBPTHREAD_STUBS"
    download $LIBPTHREAD_STUBS_MIRROR $LIBPTHREAD_STUBS
    extract $LIBPTHREAD_STUBS
    apply_patches $LIBPTHREAD_STUBS_DIR $LIBPTHREAD_STUBS
    pushd $TOP_DIR
    cd $LIBPTHREAD_STUBS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBPTHREAD_STUBS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    popd
    touch "$STATE_DIR/libpthread_stubs-${LIBPTHREAD_STUBS_VERSION}"
}

build_libpthread_stubs
