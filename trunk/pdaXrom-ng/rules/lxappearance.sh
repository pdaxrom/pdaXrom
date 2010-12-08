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

LXAPPEARANCE_VERSION=0.5.0
LXAPPEARANCE=lxappearance-${LXAPPEARANCE_VERSION}.tar.gz
LXAPPEARANCE_MIRROR=http://downloads.sourceforge.net/project/lxde/LXAppearance
LXAPPEARANCE_DIR=$BUILD_DIR/lxappearance-${LXAPPEARANCE_VERSION}
LXAPPEARANCE_ENV="$CROSS_ENV_AC"

build_lxappearance() {
    test -e "$STATE_DIR/lxappearance.installed" && return
    banner "Build lxappearance"
    download $LXAPPEARANCE_MIRROR $LXAPPEARANCE
    extract $LXAPPEARANCE
    apply_patches $LXAPPEARANCE_DIR $LXAPPEARANCE
    pushd $TOP_DIR
    cd $LXAPPEARANCE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$LXAPPEARANCE_ENV \
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
    touch "$STATE_DIR/lxappearance.installed"
}

build_lxappearance
