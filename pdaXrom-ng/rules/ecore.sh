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

ECORE_VERSION=1.0.0.beta3
ECORE=ecore-${ECORE_VERSION}.tar.bz2
ECORE_MIRROR=http://download.enlightenment.org/releases
ECORE_DIR=$BUILD_DIR/ecore-${ECORE_VERSION}
ECORE_ENV="$CROSS_ENV_AC"

build_ecore() {
    test -e "$STATE_DIR/ecore.installed" && return
    banner "Build ecore"
    download $ECORE_MIRROR $ECORE
    extract $ECORE
    apply_patches $ECORE_DIR $ECORE
    pushd $TOP_DIR
    cd $ECORE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ECORE_ENV \
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
    touch "$STATE_DIR/ecore.installed"
}

build_ecore
