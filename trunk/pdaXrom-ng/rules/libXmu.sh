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

LIBXMU_VERSION=1.1.0
LIBXMU=libXmu-${LIBXMU_VERSION}.tar.bz2
LIBXMU_MIRROR=ftp://ftp.freedesktop.org/pub/xorg/individual/lib
LIBXMU_DIR=$BUILD_DIR/libXmu-${LIBXMU_VERSION}
LIBXMU_ENV=

build_libXmu() {
    test -e "$STATE_DIR/libXmu-${LIBXMU_VERSION}" && return
    banner "Build $LIBXMU"
    download $LIBXMU_MIRROR $LIBXMU
    extract $LIBXMU
    apply_patches $LIBXMU_DIR $LIBXMU
    pushd $TOP_DIR
    cd $LIBXMU_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBXMU_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc || error
    )
    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libXmu-${LIBXMU_VERSION}"
}

build_libXmu
