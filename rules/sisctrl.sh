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

SISCTRL_VERSION=0.0.20051202
SISCTRL=sisctrl-${SISCTRL_VERSION}.tar.gz
SISCTRL_MIRROR=http://www.winischhofer.net/sis/
SISCTRL_DIR=$BUILD_DIR/sisctrl-${SISCTRL_VERSION}
SISCTRL_ENV="$CROSS_ENV_AC"

build_sisctrl() {
    test -e "$STATE_DIR/sisctrl.installed" && return
    banner "Build sisctrl"
    download $SISCTRL_MIRROR $SISCTRL
    extract $SISCTRL
    apply_patches $SISCTRL_DIR $SISCTRL
    pushd $TOP_DIR
    cd $SISCTRL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$SISCTRL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    --with-xv-path=$TARGET_LIB \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init
    install_fakeroot_finish || error

    error "update install"

    popd
    touch "$STATE_DIR/sisctrl.installed"
}

build_sisctrl
