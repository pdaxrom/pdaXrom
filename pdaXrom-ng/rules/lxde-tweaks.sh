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

LXDE_TWEAKS_VERSION=0.0
LXDE_TWEAKS=lxde-tweaks-${LXDE_TWEAKS_VERSION}.zip
LXDE_TWEAKS_MIRROR=http://no.ya
LXDE_TWEAKS_DIR=$BUILD_DIR/lxde-tweaks-${LXDE_TWEAKS_VERSION}
LXDE_TWEAKS_ENV="$CROSS_ENV_AC"

build_lxde_tweaks() {
    test -e "$STATE_DIR/lxde_tweaks.installed" && return
    banner "Build lxde-tweaks"

    cp -a $GENERICFS_DIR/themes/gnome $ROOTFS_DIR/usr/share/icons/ || error "install addon lxde icons"

    find $ROOTFS_DIR/usr/share/icons/ -type d -name ".svn" | xargs rm -rf

    $INSTALL -D -m 644 $GENERICFS_DIR/default-apps/config/default $ROOTFS_DIR/etc/default/applications/default || error "install wrappers default config"

    for f in webbrowser xterminal textedit; do
	$INSTALL -D -m 755 $GENERICFS_DIR/default-apps/bin/$f $ROOTFS_DIR/usr/bin/$f || error "install application wrapper"
	$INSTALL -D -m 755 $GENERICFS_DIR/default-apps/desktop/$f.desktop $ROOTFS_DIR/usr/share/applications/$f.desktop || error "install application desktop file"
    done

    touch "$STATE_DIR/lxde_tweaks.installed"
}

build_lxde_tweaks
