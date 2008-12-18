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

LXDE_MENU_CACHE=menu-cache-0.2.2.tar.gz
LXDE_MENU_CACHE_MIRROR=http://downloads.sourceforge.net/lxde
LXDE_MENU_CACHE_DIR=$BUILD_DIR/menu-cache-0.2.2
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
	./configure --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --x-includes=$TARGET_INC \
	    --x-libraries=$TARGET_LIB
    ) || error "configure"
    
    make $MAKEARGS || error

    install_sysroot_files || error

    $INSTALL -D -m 644 libmenu-cache/.libs/libmenu-cache.so.0.0.0 $ROOTFS_DIR/usr/lib/libmenu-cache.so.0.0.0 || error
    ln -sf libmenu-cache.so.0.0.0 $ROOTFS_DIR/usr/lib/libmenu-cache.so.0
    ln -sf libmenu-cache.so.0.0.0 $ROOTFS_DIR/usr/lib/libmenu-cache.so
    $STRIP $ROOTFS_DIR/usr/lib/libmenu-cache.so.0.0.0
    
    for f in menu-cache-daemon/menu-cached menu-cache-gen/.libs/menu-cache-gen; do
	$INSTALL -D -m 755 $f $ROOTFS_DIR/usr/bin/${f/*\//} || error "install $f"
	$STRIP $ROOTFS_DIR/usr/bin/${f/*\//}
    done

    popd
    touch "$STATE_DIR/lxde_menu_cache.installed"
}

build_lxde_menu_cache
