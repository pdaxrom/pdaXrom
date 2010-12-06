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

LIBDVBPSI5_VERSION=0.1.6
LIBDVBPSI5=libdvbpsi5-${LIBDVBPSI5_VERSION}.tar.gz
LIBDVBPSI5_MIRROR=http://download.videolan.org/pub/libdvbpsi/0.1.6
LIBDVBPSI5_DIR=$BUILD_DIR/libdvbpsi5-${LIBDVBPSI5_VERSION}
LIBDVBPSI5_ENV="$CROSS_ENV_AC"

build_libdvbpsi5() {
    test -e "$STATE_DIR/libdvbpsi5.installed" && return
    banner "Build libdvbpsi5"
    download $LIBDVBPSI5_MIRROR $LIBDVBPSI5
    extract $LIBDVBPSI5
    apply_patches $LIBDVBPSI5_DIR $LIBDVBPSI5
    pushd $TOP_DIR
    cd $LIBDVBPSI5_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBDVBPSI5_ENV \
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
    touch "$STATE_DIR/libdvbpsi5.installed"
}

build_libdvbpsi5
