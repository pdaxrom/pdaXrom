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

XFCE4_PANEL_VERSION=4.7.6
XFCE4_PANEL=xfce4-panel-${XFCE4_PANEL_VERSION}.tar.bz2
XFCE4_PANEL_MIRROR=http://mocha.xfce.org/archive/xfce/4.8pre2/src
XFCE4_PANEL_DIR=$BUILD_DIR/xfce4-panel-${XFCE4_PANEL_VERSION}
XFCE4_PANEL_ENV="$CROSS_ENV_AC"

build_xfce4_panel() {
    test -e "$STATE_DIR/xfce4_panel.installed" && return
    banner "Build xfce4-panel"
    download $XFCE4_PANEL_MIRROR $XFCE4_PANEL
    extract $XFCE4_PANEL
    apply_patches $XFCE4_PANEL_DIR $XFCE4_PANEL
    pushd $TOP_DIR
    cd $XFCE4_PANEL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFCE4_PANEL_ENV \
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
    touch "$STATE_DIR/xfce4_panel.installed"
}

build_xfce4_panel
