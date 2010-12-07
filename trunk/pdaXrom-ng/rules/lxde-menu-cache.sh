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

LXDE_MENU_CACHE_VERSION=0.3.2
LXDE_MENU_CACHE=menu-cache-${LXDE_MENU_CACHE_VERSION}.tar.gz
LXDE_MENU_CACHE_MIRROR=http://downloads.sourceforge.net/lxde
LXDE_MENU_CACHE_DIR=$BUILD_DIR/menu-cache-${LXDE_MENU_CACHE_VERSION}
LXDE_MENU_CACHE_ENV="$CROSS_ENV_AC"

build_lxde_menu_cache() {
    test -e "$STATE_DIR/lxde_menu_cache.installed" && return
    banner "Build lxde-menu-cache"
    download $LXDE_MENU_CACHE_MIRROR $LXDE_MENU_CACHE
    extract $LXDE_MENU_CACHE
    apply_patches $LXDE_MENU_CACHE_DIR $LXDE_MENU_CACHE
    pushd $TOP_DIR
    cd $LXDE_MENU_CACHE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDE_MENU_CACHE_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/lxde-menu-cache \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/lxde_menu_cache.installed"
}

build_lxde_menu_cache
