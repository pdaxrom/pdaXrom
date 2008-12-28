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

LXDE_LXTERMINAL=lxterminal-0.1.4.tar.gz
LXDE_LXTERMINAL_MIRROR=http://downloads.sourceforge.net/lxde
LXDE_LXTERMINAL_DIR=$BUILD_DIR/lxterminal-0.1.4
LXDE_LXTERMINAL_ENV="$CROSS_ENV_AC"

build_lxde_lxterminal() {
    test -e "$STATE_DIR/lxde_lxterminal.installed" && return
    banner "Build lxde-lxterminal"
    download $LXDE_LXTERMINAL_MIRROR $LXDE_LXTERMINAL
    extract $LXDE_LXTERMINAL
    apply_patches $LXDE_LXTERMINAL_DIR $LXDE_LXTERMINAL
    pushd $TOP_DIR
    cd $LXDE_LXTERMINAL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDE_LXTERMINAL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make -C data DESTDIR=$ROOTFS_DIR/ install || error
    
    $INSTALL -D -m 755 src/lxterminal $ROOTFS_DIR/usr/bin/lxterminal || error
    $STRIP $ROOTFS_DIR/usr/bin/lxterminal

    popd
    touch "$STATE_DIR/lxde_lxterminal.installed"
}

build_lxde_lxterminal
