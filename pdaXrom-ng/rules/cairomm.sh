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

CAIROMM_VERSION=1.9.6
CAIROMM=cairomm-${CAIROMM_VERSION}.tar.gz
CAIROMM_MIRROR=http://cairographics.org/releases
CAIROMM_DIR=$BUILD_DIR/cairomm-${CAIROMM_VERSION}
CAIROMM_ENV="$CROSS_ENV_AC"

build_cairomm() {
    test -e "$STATE_DIR/cairomm.installed" && return
    banner "Build cairomm"
    download $CAIROMM_MIRROR $CAIROMM
    extract $CAIROMM
    apply_patches $CAIROMM_DIR $CAIROMM
    pushd $TOP_DIR
    cd $CAIROMM_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$CAIROMM_ENV \
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
    touch "$STATE_DIR/cairomm.installed"
}

build_cairomm
