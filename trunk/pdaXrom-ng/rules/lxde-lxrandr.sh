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

LXDE_LXRANDR=lxrandr-0.1.tar.gz
LXDE_LXRANDR_MIRROR=http://downloads.sourceforge.net/lxde
LXDE_LXRANDR_DIR=$BUILD_DIR/lxrandr-0.1
LXDE_LXRANDR_ENV="$CROSS_ENV_AC"

build_lxde_lxrandr() {
    test -e "$STATE_DIR/lxde_lxrandr.installed" && return
    banner "Build lxde-lxrandr"
    download $LXDE_LXRANDR_MIRROR $LXDE_LXRANDR
    extract $LXDE_LXRANDR
    apply_patches $LXDE_LXRANDR_DIR $LXDE_LXRANDR
    pushd $TOP_DIR
    cd $LXDE_LXRANDR_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDE_LXRANDR_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    $INSTALL -D -m 755 src/lxrandr $ROOTFS_DIR/usr/bin/lxrandr || error
    $STRIP $ROOTFS_DIR/usr/bin/lxrandr || error
    
    $INSTALL -D -m 644 data/lxrandr.desktop $ROOTFS_DIR/usr/share/applications/lxrandr.desktop || error

    popd
    touch "$STATE_DIR/lxde_lxrandr.installed"
}

build_lxde_lxrandr
