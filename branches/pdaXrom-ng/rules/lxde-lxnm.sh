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

LXDE_LXNM=lxnm-0.2.2.tar.gz
LXDE_LXNM_MIRROR=http://downloads.sourceforge.net/lxde
LXDE_LXNM_DIR=$BUILD_DIR/lxnm-0.2.2
LXDE_LXNM_ENV="$CROSS_ENV_AC"

build_lxde_lxnm() {
    test -e "$STATE_DIR/lxde_lxnm.installed" && return
    banner "Build lxde-lxnm"
    download $LXDE_LXNM_MIRROR $LXDE_LXNM
    extract $LXDE_LXNM
    apply_patches $LXDE_LXNM_DIR $LXDE_LXNM
    pushd $TOP_DIR
    cd $LXDE_LXNM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDE_LXNM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"
    
    make $MAKEARGS || error

    make -C data DESTDIR=$ROOTFS_DIR/ install || error
    $INSTALL -D -m 755 src/lxnm $ROOTFS_DIR/usr/sbin/lxnm || error
    $STRIP $ROOTFS_DIR/usr/sbin/lxnm

    popd
    touch "$STATE_DIR/lxde_lxnm.installed"
}

build_lxde_lxnm
