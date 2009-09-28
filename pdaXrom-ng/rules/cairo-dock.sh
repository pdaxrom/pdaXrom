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

CAIRO_DOCK_VERSION=2.0.8.2
CAIRO_DOCK=cairo-dock-${CAIRO_DOCK_VERSION}.tar.bz2
CAIRO_DOCK_MIRROR=http://download.berlios.de/cairo-dock
CAIRO_DOCK_DIR=$BUILD_DIR/cairo-dock-${CAIRO_DOCK_VERSION}
CAIRO_DOCK_ENV="$CROSS_ENV_AC"

build_cairo_dock() {
    test -e "$STATE_DIR/cairo_dock.installed" && return
    banner "Build cairo-dock"
    download $CAIRO_DOCK_MIRROR $CAIRO_DOCK
    extract $CAIRO_DOCK
    apply_patches $CAIRO_DOCK_DIR $CAIRO_DOCK
    pushd $TOP_DIR
    cd $CAIRO_DOCK_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$CAIRO_DOCK_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    sed -i -e 's|pluginsdir=\${exec_prefix}|pluginsdir=/usr|' cairo-dock.pc
    sed -i -e 's|pluginsdatadir=\${prefix}|pluginsdatadir=/usr|' cairo-dock.pc
    sed -i -e 's|themesdir=\${prefix}|themesdir=/usr|' cairo-dock.pc

    install_sysroot_files || error

    install_fakeroot_init
    rm -f fakeroot/usr/bin/cairo-dock-update.sh fakeroot/usr/bin/launch-cairo-dock-after-beryl.sh
    rm -rf fakeroot/usr/include fakeroot/usr/lib fakeroot/usr/share/locale
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/cairo_dock.installed"
}

build_cairo_dock
