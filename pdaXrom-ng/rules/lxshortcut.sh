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

LXSHORTCUT_VERSION=0.1.1
LXSHORTCUT=lxshortcut-${LXSHORTCUT_VERSION}.tar.gz
LXSHORTCUT_MIRROR=http://downloads.sourceforge.net/project/lxde/LXShortcut%20%28edit%20app%20shortcut%29/LXShortcut%200.1.1
LXSHORTCUT_DIR=$BUILD_DIR/lxshortcut-${LXSHORTCUT_VERSION}
LXSHORTCUT_ENV="$CROSS_ENV_AC"

build_lxshortcut() {
    test -e "$STATE_DIR/lxshortcut.installed" && return
    banner "Build lxshortcut"
    download $LXSHORTCUT_MIRROR $LXSHORTCUT
    extract $LXSHORTCUT
    apply_patches $LXSHORTCUT_DIR $LXSHORTCUT
    pushd $TOP_DIR
    cd $LXSHORTCUT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXSHORTCUT_ENV \
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
    touch "$STATE_DIR/lxshortcut.installed"
}

build_lxshortcut
