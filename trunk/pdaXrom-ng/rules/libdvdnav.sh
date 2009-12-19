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

LIBDVDNAV_VERSION=4.1.3
LIBDVDNAV=libdvdnav-${LIBDVDNAV_VERSION}.tar.bz2
LIBDVDNAV_MIRROR=http://www.mplayerhq.hu/MPlayer/releases/dvdnav
LIBDVDNAV_DIR=$BUILD_DIR/libdvdnav-${LIBDVDNAV_VERSION}
LIBDVDNAV_ENV="$CROSS_ENV_AC"

build_libdvdnav() {
    test -e "$STATE_DIR/libdvdnav.installed" && return
    banner "Build libdvdnav"
    download $LIBDVDNAV_MIRROR $LIBDVDNAV
    extract $LIBDVDNAV
    apply_patches $LIBDVDNAV_DIR $LIBDVDNAV
    pushd $TOP_DIR
    cd $LIBDVDNAV_DIR
    autoreconf -i || error "generate configure"
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBDVDNAV_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    rm -rf fakeroot/usr/bin
    install_fakeroot_finish || error

    ln -sf ${TARGET_BIN_DIR}/bin/dvdnav-config ${HOST_BIN_DIR}/bin/dvdnav-config

    popd
    touch "$STATE_DIR/libdvdnav.installed"
}

build_libdvdnav
