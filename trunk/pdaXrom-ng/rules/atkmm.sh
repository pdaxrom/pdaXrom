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

ATKMM_VERSION=2.22.1
ATKMM=atkmm-${ATKMM_VERSION}.tar.bz2
ATKMM_MIRROR=http://ftp.acc.umu.se/pub/GNOME/sources/atkmm/2.22
ATKMM_DIR=$BUILD_DIR/atkmm-${ATKMM_VERSION}
ATKMM_ENV="$CROSS_ENV_AC"

build_atkmm() {
    test -e "$STATE_DIR/atkmm.installed" && return
    banner "Build atkmm"
    download $ATKMM_MIRROR $ATKMM
    extract $ATKMM
    apply_patches $ATKMM_DIR $ATKMM
    pushd $TOP_DIR
    cd $ATKMM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ATKMM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    rm -rf fakeroot/usr/lib/atkmm-1.6 fakeroot/usr/share/devhelp

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/atkmm.installed"
}

build_atkmm
