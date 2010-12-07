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

GTKMM_VERSION=2.22.0
GTKMM=gtkmm-${GTKMM_VERSION}.tar.bz2
GTKMM_MIRROR=http://ftp.gnome.org/pub/GNOME/sources/gtkmm/2.22
GTKMM_DIR=$BUILD_DIR/gtkmm-${GTKMM_VERSION}
GTKMM_ENV="$CROSS_ENV_AC"

build_gtkmm() {
    test -e "$STATE_DIR/gtkmm.installed" && return
    banner "Build gtkmm"
    download $GTKMM_MIRROR $GTKMM
    extract $GTKMM
    apply_patches $GTKMM_DIR $GTKMM
    pushd $TOP_DIR
    cd $GTKMM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$GTKMM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    rm -rf fakeroot/usr/lib/gdkmm-2.4 fakeroot/usr/lib/gtkmm-2.4 fakeroot/usr/share/devhelp fakeroot/usr/share/gtkmm-2.4
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/gtkmm.installed"
}

build_gtkmm
