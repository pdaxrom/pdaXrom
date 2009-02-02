#
# packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

LXDE_LXLAUNCHER=lxlauncher-0.2.tar.gz
LXDE_LXLAUNCHER_MIRROR=http://downloads.sourceforge.net/lxde
LXDE_LXLAUNCHER_DIR=$BUILD_DIR/lxlauncher-0.2
LXDE_LXLAUNCHER_ENV="$CROSS_ENV_AC"

build_lxde_lxlauncher() {
    test -e "$STATE_DIR/lxde_lxlauncher.installed" && return
    banner "Build lxde-lxlauncher"
    download $LXDE_LXLAUNCHER_MIRROR $LXDE_LXLAUNCHER
    extract $LXDE_LXLAUNCHER
    apply_patches $LXDE_LXLAUNCHER_DIR $LXDE_LXLAUNCHER
    pushd $TOP_DIR
    cd $LXDE_LXLAUNCHER_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDE_LXLAUNCHER_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    error "update install"

    popd
    touch "$STATE_DIR/lxde_lxlauncher.installed"
}

build_lxde_lxlauncher
