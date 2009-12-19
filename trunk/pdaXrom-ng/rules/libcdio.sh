#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

LIBCDIO_VERSION=0.82
LIBCDIO=libcdio-${LIBCDIO_VERSION}.tar.gz
LIBCDIO_MIRROR=http://ftp.gnu.org/gnu/libcdio
LIBCDIO_DIR=$BUILD_DIR/libcdio-${LIBCDIO_VERSION}
LIBCDIO_ENV="$CROSS_ENV_AC"

build_libcdio() {
    test -e "$STATE_DIR/libcdio.installed" && return
    banner "Build libcdio"
    download $LIBCDIO_MIRROR $LIBCDIO
    extract $LIBCDIO
    apply_patches $LIBCDIO_DIR $LIBCDIO
    pushd $TOP_DIR
    cd $LIBCDIO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBCDIO_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libcdio.installed"
}

build_libcdio
