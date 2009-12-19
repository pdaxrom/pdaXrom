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

LIBDVDCSS_VERSION=1.2.9
LIBDVDCSS=libdvdcss-${LIBDVDCSS_VERSION}.tar.bz2
LIBDVDCSS_MIRROR=http://download.videolan.org/pub/videolan/libdvdcss/1.2.9
LIBDVDCSS_DIR=$BUILD_DIR/libdvdcss-${LIBDVDCSS_VERSION}
LIBDVDCSS_ENV="$CROSS_ENV_AC"

build_libdvdcss() {
    test -e "$STATE_DIR/libdvdcss.installed" && return
    banner "Build libdvdcss"
    download $LIBDVDCSS_MIRROR $LIBDVDCSS
    extract $LIBDVDCSS
    apply_patches $LIBDVDCSS_DIR $LIBDVDCSS
    pushd $TOP_DIR
    cd $LIBDVDCSS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBDVDCSS_ENV \
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
    touch "$STATE_DIR/libdvdcss.installed"
}

build_libdvdcss
