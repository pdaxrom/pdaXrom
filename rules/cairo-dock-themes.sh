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

CAIRO_DOCK_THEMES_VERSION=1.6.3.1
CAIRO_DOCK_THEMES=cairo-dock-themes-${CAIRO_DOCK_THEMES_VERSION}.tar.bz2
CAIRO_DOCK_THEMES_MIRROR=http://download.berlios.de/cairo-dock
CAIRO_DOCK_THEMES_DIR=$BUILD_DIR/cairo-dock-themes-${CAIRO_DOCK_THEMES_VERSION}
CAIRO_DOCK_THEMES_ENV="$CROSS_ENV_AC"

build_cairo_dock_themes() {
    test -e "$STATE_DIR/cairo_dock_themes.installed" && return
    banner "Build cairo-dock-themes"
    download $CAIRO_DOCK_THEMES_MIRROR $CAIRO_DOCK_THEMES
    extract $CAIRO_DOCK_THEMES
    apply_patches $CAIRO_DOCK_THEMES_DIR $CAIRO_DOCK_THEMES
    pushd $TOP_DIR
    cd $CAIRO_DOCK_THEMES_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$CAIRO_DOCK_THEMES_ENV \
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
    touch "$STATE_DIR/cairo_dock_themes.installed"
}

build_cairo_dock_themes
