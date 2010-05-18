#
# packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

FARSIGHT2_VERSION=0.0.14
FARSIGHT2=farsight2-${FARSIGHT2_VERSION}.tar.gz
FARSIGHT2_MIRROR=http://farsight.freedesktop.org/releases/farsight2
FARSIGHT2_DIR=$BUILD_DIR/farsight2-${FARSIGHT2_VERSION}
FARSIGHT2_ENV="$CROSS_ENV_AC"

build_farsight2() {
    test -e "$STATE_DIR/farsight2.installed" && return
    banner "Build farsight2"
    download $FARSIGHT2_MIRROR $FARSIGHT2
    extract $FARSIGHT2
    apply_patches $FARSIGHT2_DIR $FARSIGHT2
    pushd $TOP_DIR
    cd $FARSIGHT2_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$FARSIGHT2_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --disable-python \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/farsight2.installed"
}

build_farsight2
