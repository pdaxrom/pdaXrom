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

LXDM_VERSION=0.3.0
LXDM=lxdm-${LXDM_VERSION}.tar.gz
LXDM_MIRROR=http://downloads.sourceforge.net/project/lxde/lxdm/lxdm-0.3.0
LXDM_DIR=$BUILD_DIR/lxdm-${LXDM_VERSION}
LXDM_ENV="$CROSS_ENV_AC"

build_lxdm() {
    test -e "$STATE_DIR/lxdm.installed" && return
    banner "Build lxdm"
    download $LXDM_MIRROR $LXDM
    extract $LXDM
    apply_patches $LXDM_DIR $LXDM
    pushd $TOP_DIR
    cd $LXDM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDM_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --libexecdir=/usr/lib/lxdm \
	    || error
    ) || error "configure"

    rm -f data/lxdm.conf

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/lxdm $ROOTFS_DIR/etc/init.d/lxdm || error "can't install lxdm init script"
    install_rc_start lxdm 99
    install_rc_stop  lxdm 01

    popd
    touch "$STATE_DIR/lxdm.installed"
}

build_lxdm
