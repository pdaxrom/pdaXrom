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

EEZE_VERSION=1.0.0.beta3
EEZE=eeze-${EEZE_VERSION}.tar.bz2
EEZE_MIRROR=http://download.enlightenment.org/releases
EEZE_DIR=$BUILD_DIR/eeze-${EEZE_VERSION}
EEZE_ENV="$CROSS_ENV_AC"

build_eeze() {
    test -e "$STATE_DIR/eeze.installed" && return
    banner "Build eeze"
    download $EEZE_MIRROR $EEZE
    extract $EEZE
    apply_patches $EEZE_DIR $EEZE
    pushd $TOP_DIR
    cd $EEZE_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$EEZE_ENV \
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
    touch "$STATE_DIR/eeze.installed"
}

build_eeze
