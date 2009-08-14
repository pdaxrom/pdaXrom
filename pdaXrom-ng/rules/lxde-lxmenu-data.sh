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

LXDE_LXMENU_DATA=lxmenu-data-0.1.tar.gz
LXDE_LXMENU_DATA_MIRROR=http://downloads.sourceforge.net/lxde
LXDE_LXMENU_DATA_DIR=$BUILD_DIR/lxmenu-data-0.1
LXDE_LXMENU_DATA_ENV="$CROSS_ENV_AC"

build_lxde_lxmenu_data() {
    test -e "$STATE_DIR/lxde_lxmenu_data.installed" && return
    banner "Build lxde-lxmenu-data"
    download $LXDE_LXMENU_DATA_MIRROR $LXDE_LXMENU_DATA
    extract $LXDE_LXMENU_DATA
    apply_patches $LXDE_LXMENU_DATA_DIR $LXDE_LXMENU_DATA
    pushd $TOP_DIR
    cd $LXDE_LXMENU_DATA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDE_LXMENU_DATA_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB
    ) || error "configure"
    
    make $MAKEARGS || error

    make $MAKEARGS DESTDIR=$ROOTFS_DIR install || error

    popd
    touch "$STATE_DIR/lxde_lxmenu_data.installed"
}

build_lxde_lxmenu_data
