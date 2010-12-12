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

THUNAR_VOLMAN_VERSION=0.5.3
THUNAR_VOLMAN=thunar-volman-${THUNAR_VOLMAN_VERSION}.tar.bz2
THUNAR_VOLMAN_MIRROR=http://archive.xfce.org/src/apps/thunar-volman/0.5
THUNAR_VOLMAN_DIR=$BUILD_DIR/thunar-volman-${THUNAR_VOLMAN_VERSION}
THUNAR_VOLMAN_ENV="$CROSS_ENV_AC"

build_thunar_volman() {
    test -e "$STATE_DIR/thunar_volman.installed" && return
    banner "Build thunar-volman"
    download $THUNAR_VOLMAN_MIRROR $THUNAR_VOLMAN
    extract $THUNAR_VOLMAN
    apply_patches $THUNAR_VOLMAN_DIR $THUNAR_VOLMAN
    pushd $TOP_DIR
    cd $THUNAR_VOLMAN_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$THUNAR_VOLMAN_ENV \
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
    touch "$STATE_DIR/thunar_volman.installed"
}

build_thunar_volman
