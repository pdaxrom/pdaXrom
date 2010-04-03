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

CAIRO_DOCK_PLUGINS_VERSION=2.1.0
CAIRO_DOCK_PLUGINS=cairo-dock-plugins-${CAIRO_DOCK_PLUGINS_VERSION}.tar.bz2
CAIRO_DOCK_PLUGINS_MIRROR=http://download.berlios.de/cairo-dock
CAIRO_DOCK_PLUGINS_DIR=$BUILD_DIR/cairo-dock-plugins-${CAIRO_DOCK_PLUGINS_VERSION}
CAIRO_DOCK_PLUGINS_ENV="$CROSS_ENV_AC"

build_cairo_dock_plugins() {
    test -e "$STATE_DIR/cairo_dock_plugins.installed" && return
    banner "Build cairo-dock-plugins"
    download $CAIRO_DOCK_PLUGINS_MIRROR $CAIRO_DOCK_PLUGINS
    extract $CAIRO_DOCK_PLUGINS
    apply_patches $CAIRO_DOCK_PLUGINS_DIR $CAIRO_DOCK_PLUGINS
    pushd $TOP_DIR
    cd $CAIRO_DOCK_PLUGINS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$CAIRO_DOCK_PLUGINS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-gnome-integration=no \
	    --enable-old-gnome-integration=no \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/cairo_dock_plugins.installed"
}

build_cairo_dock_plugins
