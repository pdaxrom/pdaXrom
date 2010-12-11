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

ENLIGHTENMENT_VERSION=0.16.999.55225
ENLIGHTENMENT=enlightenment-${ENLIGHTENMENT_VERSION}.tar.bz2
ENLIGHTENMENT_MIRROR=http://download.enlightenment.org/snapshots/2010-12-03
ENLIGHTENMENT_DIR=$BUILD_DIR/enlightenment-${ENLIGHTENMENT_VERSION}
ENLIGHTENMENT_ENV="$CROSS_ENV_AC"

build_enlightenment() {
    test -e "$STATE_DIR/enlightenment.installed" && return
    banner "Build enlightenment"
    download $ENLIGHTENMENT_MIRROR $ENLIGHTENMENT
    extract $ENLIGHTENMENT
    apply_patches $ENLIGHTENMENT_DIR $ENLIGHTENMENT
    pushd $TOP_DIR
    cd $ENLIGHTENMENT_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$ENLIGHTENMENT_ENV \
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
    touch "$STATE_DIR/enlightenment.installed"
}

build_enlightenment
