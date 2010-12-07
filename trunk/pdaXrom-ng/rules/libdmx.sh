#
# packet template
#
# Copyright (C) 2010 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

LIBDMX_VERSION=1.1.1
LIBDMX=libdmx-${LIBDMX_VERSION}.tar.bz2
LIBDMX_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBDMX_DIR=$BUILD_DIR/libdmx-${LIBDMX_VERSION}
LIBDMX_ENV="$CROSS_ENV_AC"

build_libdmx() {
    test -e "$STATE_DIR/libdmx.installed" && return
    banner "Build libdmx"
    download $LIBDMX_MIRROR $LIBDMX
    extract $LIBDMX
    apply_patches $LIBDMX_DIR $LIBDMX
    pushd $TOP_DIR
    cd $LIBDMX_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBDMX_ENV \
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
    touch "$STATE_DIR/libdmx.installed"
}

build_libdmx
