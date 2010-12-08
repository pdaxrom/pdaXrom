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

LXDE_ICON_THEME_VERSION=0.0.1
LXDE_ICON_THEME=lxde-icon-theme-${LXDE_ICON_THEME_VERSION}.tar.bz2
LXDE_ICON_THEME_MIRROR=http://downloads.sourceforge.net/project/lxde/LXDE%20Icon%20Theme/lxde-icon-theme-0.0.1
LXDE_ICON_THEME_DIR=$BUILD_DIR/lxde-icon-theme-${LXDE_ICON_THEME_VERSION}
LXDE_ICON_THEME_ENV="$CROSS_ENV_AC"

build_lxde_icon_theme() {
    test -e "$STATE_DIR/lxde_icon_theme.installed" && return
    banner "Build lxde-icon-theme"
    download $LXDE_ICON_THEME_MIRROR $LXDE_ICON_THEME
    extract $LXDE_ICON_THEME
    apply_patches $LXDE_ICON_THEME_DIR $LXDE_ICON_THEME
    pushd $TOP_DIR
    cd $LXDE_ICON_THEME_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDE_ICON_THEME_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/lxde_icon_theme.installed"
}

build_lxde_icon_theme
