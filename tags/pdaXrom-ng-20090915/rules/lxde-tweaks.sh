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

    touch "$STATE_DIR/lxde_tweaks.installed"
}

build_lxde_tweaks
