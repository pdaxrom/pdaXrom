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

EMBRYO_VERSION=1.0.0.beta3
EMBRYO=embryo-${EMBRYO_VERSION}.tar.bz2
EMBRYO_MIRROR=http://download.enlightenment.org/releases
EMBRYO_DIR=$BUILD_DIR/embryo-${EMBRYO_VERSION}
EMBRYO_ENV="$CROSS_ENV_AC"

build_embryo() {
    test -e "$STATE_DIR/embryo.installed" && return
    banner "Build embryo"
    download $EMBRYO_MIRROR $EMBRYO
    extract $EMBRYO
    apply_patches $EMBRYO_DIR $EMBRYO
    pushd $TOP_DIR
    cd $EMBRYO_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EMBRYO_ENV \
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
    touch "$STATE_DIR/embryo.installed"
}

build_embryo
