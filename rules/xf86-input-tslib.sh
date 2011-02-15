#
# packet template
#
# Copyright (C) 2009 by Adrian Crutchfield <insearchof@inventgen-solutions.com>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

XF86_INPUT_TSLIB_VERSION=0.0.6
XF86_INPUT_TSLIB=xf86-input-tslib-${XF86_INPUT_TSLIB_VERSION}.tar.bz2
XF86_INPUT_TSLIB_MIRROR=http://pengutronix.de/software/xf86-input-tslib/download/
XF86_INPUT_TSLIB_DIR=$BUILD_DIR/xf86-input-tslib-${XF86_INPUT_TSLIB_VERSION}
XF86_INPUT_TSLIB_ENV="$CROSS_ENV_AC"

build_xf86_input_tslib() {
    test -e "$STATE_DIR/xf86_input_tslib.installed" && return
    banner "Build xf86-input-tslib"
    download $XF86_INPUT_TSLIB_MIRROR $XF86_INPUT_TSLIB
    extract $XF86_INPUT_TSLIB
    apply_patches $XF86_INPUT_TSLIB_DIR $XF86_INPUT_TSLIB
    pushd $TOP_DIR
    cd $XF86_INPUT_TSLIB_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XF86_INPUT_TSLIB_ENV \
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
    touch "$STATE_DIR/xf86_input_tslib.installed"
}

build_xf86_input_tslib
