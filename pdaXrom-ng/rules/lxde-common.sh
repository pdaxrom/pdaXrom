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

LXDE_COMMON_VERSION=0.5.0
LXDE_COMMON=lxde-common-${LXDE_COMMON_VERSION}.tar.gz
LXDE_COMMON_MIRROR=http://downloads.sourceforge.net/project/lxde/lxde-common%20%28default%20config%29/lxde-common%200.5.0
LXDE_COMMON_DIR=$BUILD_DIR/lxde-common-${LXDE_COMMON_VERSION}
LXDE_COMMON_ENV="$CROSS_ENV_AC"

build_lxde_common() {
    test -e "$STATE_DIR/lxde_common.installed" && return
    banner "Build lxde-common"
    download $LXDE_COMMON_MIRROR $LXDE_COMMON
    extract $LXDE_COMMON
    apply_patches $LXDE_COMMON_DIR $LXDE_COMMON
    pushd $TOP_DIR
    cd $LXDE_COMMON_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXDE_COMMON_ENV \
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
    touch "$STATE_DIR/lxde_common.installed"
}

build_lxde_common
