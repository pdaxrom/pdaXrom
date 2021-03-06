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

EINA_VERSION=1.0.0.beta3
EINA=eina-${EINA_VERSION}.tar.bz2
EINA_MIRROR=http://download.enlightenment.org/releases
EINA_DIR=$BUILD_DIR/eina-${EINA_VERSION}
EINA_ENV="$CROSS_ENV_AC"

build_eina() {
    test -e "$STATE_DIR/eina.installed" && return
    banner "Build eina"
    download $EINA_MIRROR $EINA
    extract $EINA
    apply_patches $EINA_DIR $EINA
    pushd $TOP_DIR
    cd $EINA_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EINA_ENV \
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
    touch "$STATE_DIR/eina.installed"
}

build_eina
