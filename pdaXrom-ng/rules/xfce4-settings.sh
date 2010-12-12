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

XFCE4_SETTINGS_VERSION=4.7.6
XFCE4_SETTINGS=xfce4-settings-${XFCE4_SETTINGS_VERSION}.tar.bz2
XFCE4_SETTINGS_MIRROR=http://archive.xfce.org/src/xfce/xfce4-settings/4.7
XFCE4_SETTINGS_DIR=$BUILD_DIR/xfce4-settings-${XFCE4_SETTINGS_VERSION}
XFCE4_SETTINGS_ENV="$CROSS_ENV_AC"

build_xfce4_settings() {
    test -e "$STATE_DIR/xfce4_settings.installed" && return
    banner "Build xfce4-settings"
    download $XFCE4_SETTINGS_MIRROR $XFCE4_SETTINGS
    extract $XFCE4_SETTINGS
    apply_patches $XFCE4_SETTINGS_DIR $XFCE4_SETTINGS
    pushd $TOP_DIR
    cd $XFCE4_SETTINGS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFCE4_SETTINGS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --enable-sound-settings \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/xfce4_settings.installed"
}

build_xfce4_settings
