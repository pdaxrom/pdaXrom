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

EVAS_VERSION=1.0.0.beta3
EVAS=evas-${EVAS_VERSION}.tar.bz2
EVAS_MIRROR=http://download.enlightenment.org/releases
EVAS_DIR=$BUILD_DIR/evas-${EVAS_VERSION}
EVAS_ENV="$CROSS_ENV_AC"

build_evas() {
    test -e "$STATE_DIR/evas.installed" && return
    banner "Build evas"
    download $EVAS_MIRROR $EVAS
    extract $EVAS
    apply_patches $EVAS_DIR $EVAS
    pushd $TOP_DIR
    cd $EVAS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EVAS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init

    rm -rf fakeroot/usr/share/evas/examples

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/evas.installed"
}

build_evas
