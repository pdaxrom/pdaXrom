#
# packet template
#
# Copyright (C) 2009 by Marina Popova <marika@tusur.info>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

LIBMNG_VERSION=1.0.10
LIBMNG=libmng-${LIBMNG_VERSION}.tar.bz2
LIBMNG_MIRROR=http://downloads.sourceforge.net/project/libmng/libmng-devel/1.0.10
LIBMNG_DIR=$BUILD_DIR/libmng-${LIBMNG_VERSION}
LIBMNG_ENV="$CROSS_ENV_AC"

build_libmng() {
    test -e "$STATE_DIR/libmng.installed" && return
    banner "Build libmng"
    download $LIBMNG_MIRROR $LIBMNG
    extract $LIBMNG
    apply_patches $LIBMNG_DIR $LIBMNG
    pushd $TOP_DIR
    cd $LIBMNG_DIR
    ./unmaintained/autogen.sh || error "create configure script"

    (
    eval \
	$CROSS_CONF_ENV \
	$LIBMNG_ENV \
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
    touch "$STATE_DIR/libmng.installed"
}

build_libmng
