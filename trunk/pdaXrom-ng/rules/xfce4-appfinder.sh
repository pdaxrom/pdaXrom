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

XFCE4_APPFINDER_VERSION=4.7.1
XFCE4_APPFINDER=xfce4-appfinder-${XFCE4_APPFINDER_VERSION}.tar.bz2
XFCE4_APPFINDER_MIRROR=http://archive.xfce.org/src/xfce/xfce4-appfinder/4.7
XFCE4_APPFINDER_DIR=$BUILD_DIR/xfce4-appfinder-${XFCE4_APPFINDER_VERSION}
XFCE4_APPFINDER_ENV="$CROSS_ENV_AC"

build_xfce4_appfinder() {
    test -e "$STATE_DIR/xfce4_appfinder.installed" && return
    banner "Build xfce4-appfinder"
    download $XFCE4_APPFINDER_MIRROR $XFCE4_APPFINDER
    extract $XFCE4_APPFINDER
    apply_patches $XFCE4_APPFINDER_DIR $XFCE4_APPFINDER
    pushd $TOP_DIR
    cd $XFCE4_APPFINDER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFCE4_APPFINDER_ENV \
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
    touch "$STATE_DIR/xfce4_appfinder.installed"
}

build_xfce4_appfinder
