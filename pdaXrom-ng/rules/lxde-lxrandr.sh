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

LXDE_LXRANDR_VERSION=0.1.1
LXDE_LXRANDR=lxrandr-${LXDE_LXRANDR_VERSION}.tar.gz
LXDE_LXRANDR_MIRROR=http://downloads.sourceforge.net/lxde
LXDE_LXRANDR_DIR=$BUILD_DIR/lxrandr-${LXDE_LXRANDR_VERSION}
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

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/lxde_lxrandr.installed"
}

build_lxde_lxrandr
