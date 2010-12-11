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

EFREET_VERSION=1.0.0.beta3
EFREET=efreet-${EFREET_VERSION}.tar.bz2
EFREET_MIRROR=http://download.enlightenment.org/releases
EFREET_DIR=$BUILD_DIR/efreet-${EFREET_VERSION}
EFREET_ENV="$CROSS_ENV_AC"

build_efreet() {
    test -e "$STATE_DIR/efreet.installed" && return
    banner "Build efreet"
    download $EFREET_MIRROR $EFREET
    extract $EFREET
    apply_patches $EFREET_DIR $EFREET
    pushd $TOP_DIR
    cd $EFREET_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EFREET_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/efreet.installed"
}

build_efreet
