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

LIBXFCEGUI4_VERSION=4.7.0
LIBXFCEGUI4=libxfcegui4-${LIBXFCEGUI4_VERSION}.tar.bz2
LIBXFCEGUI4_MIRROR=http://archive.xfce.org/src/xfce/libxfcegui4/4.7
LIBXFCEGUI4_DIR=$BUILD_DIR/libxfcegui4-${LIBXFCEGUI4_VERSION}
LIBXFCEGUI4_ENV="$CROSS_ENV_AC"

build_libxfcegui4() {
    test -e "$STATE_DIR/libxfcegui4.installed" && return
    banner "Build libxfcegui4"
    download $LIBXFCEGUI4_MIRROR $LIBXFCEGUI4
    extract $LIBXFCEGUI4
    apply_patches $LIBXFCEGUI4_DIR $LIBXFCEGUI4
    pushd $TOP_DIR
    cd $LIBXFCEGUI4_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXFCEGUI4_ENV \
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
    touch "$STATE_DIR/libxfcegui4.installed"
}

build_libxfcegui4
