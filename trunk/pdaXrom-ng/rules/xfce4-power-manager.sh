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

XFCE4_POWER_MANAGER_VERSION=1.0.1
XFCE4_POWER_MANAGER=xfce4-power-manager-${XFCE4_POWER_MANAGER_VERSION}.tar.bz2
XFCE4_POWER_MANAGER_MIRROR=http://archive.xfce.org/src/apps/xfce4-power-manager/1.0
XFCE4_POWER_MANAGER_DIR=$BUILD_DIR/xfce4-power-manager-${XFCE4_POWER_MANAGER_VERSION}
XFCE4_POWER_MANAGER_ENV="$CROSS_ENV_AC"

build_xfce4_power_manager() {
    test -e "$STATE_DIR/xfce4_power_manager.installed" && return
    banner "Build xfce4-power-manager"
    download $XFCE4_POWER_MANAGER_MIRROR $XFCE4_POWER_MANAGER
    extract $XFCE4_POWER_MANAGER
    apply_patches $XFCE4_POWER_MANAGER_DIR $XFCE4_POWER_MANAGER
    pushd $TOP_DIR
    cd $XFCE4_POWER_MANAGER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFCE4_POWER_MANAGER_ENV \
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
    touch "$STATE_DIR/xfce4_power_manager.installed"
}

build_xfce4_power_manager
