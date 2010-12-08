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

LIBDRM_VERSION=2.4.22
LIBDRM=libdrm-${LIBDRM_VERSION}.tar.bz2
LIBDRM_MIRROR=http://dri.freedesktop.org/libdrm
LIBDRM_DIR=$BUILD_DIR/libdrm-${LIBDRM_VERSION}
LIBDRM_ENV=

build_libdrm() {
    test -e "$STATE_DIR/libdrm-${LIBDRM_VERSION}" && return
    banner "Build $LIBDRM"
    download $LIBDRM_MIRROR $LIBDRM
    extract $LIBDRM
    apply_patches $LIBDRM_DIR $LIBDRM
    pushd $TOP_DIR
    cd $LIBDRM_DIR
    local C_ARGS=
    case $TARGET_ARCH in
    mips*)
	C_ARGS="--disable-intel --disable-radeon"
    esac
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBDRM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    $C_ARGS \
	    || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libdrm-${LIBDRM_VERSION}"
}

build_libdrm
