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

LIBOIL_VERSION=0.3.16
LIBOIL=liboil-${LIBOIL_VERSION}.tar.gz
LIBOIL_MIRROR=http://liboil.freedesktop.org/download
LIBOIL_DIR=$BUILD_DIR/liboil-${LIBOIL_VERSION}
LIBOIL_ENV="$CROSS_ENV_AC"

build_liboil() {
    test -e "$STATE_DIR/liboil.installed" && return
    banner "Build liboil"
    download $LIBOIL_MIRROR $LIBOIL
    extract $LIBOIL
    apply_patches $LIBOIL_DIR $LIBOIL
    pushd $TOP_DIR
    cd $LIBOIL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBOIL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init || error
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/liboil.installed"
}

build_liboil
