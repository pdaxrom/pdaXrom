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

#LIBDVDREAD_VERSION=0.9.7
LIBDVDREAD_VERSION=4.1.3
LIBDVDREAD=libdvdread-${LIBDVDREAD_VERSION}.tar.bz2
#LIBDVDREAD_MIRROR=http://www.dtek.chalmers.se/groups/dvd/dist
LIBDVDREAD_MIRROR=http://www.mplayerhq.hu/MPlayer/releases/dvdnav
LIBDVDREAD_DIR=$BUILD_DIR/libdvdread-${LIBDVDREAD_VERSION}
LIBDVDREAD_ENV="$CROSS_ENV_AC"

build_libdvdread() {
    test -e "$STATE_DIR/libdvdread.installed" && return
    banner "Build libdvdread"
    download $LIBDVDREAD_MIRROR $LIBDVDREAD
    extract $LIBDVDREAD
    apply_patches $LIBDVDREAD_DIR $LIBDVDREAD
    pushd $TOP_DIR
    cd $LIBDVDREAD_DIR
    ./autogen.sh || error "generate configure"
    (
    eval \
	$CROSS_CONF_ENV \
	$LIBDVDREAD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf ${TARGET_BIN_DIR}/bin/dvdread-config ${HOST_BIN_DIR}/bin/dvdread-config

    install_fakeroot_init
    rm -rf fakeroot/usr/bin
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/libdvdread.installed"
}

build_libdvdread
