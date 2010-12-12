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

XFWM4_VERSION=4.7.3
XFWM4=xfwm4-${XFWM4_VERSION}.tar.bz2
XFWM4_MIRROR=http://archive.xfce.org/src/xfce/xfwm4/4.7
XFWM4_DIR=$BUILD_DIR/xfwm4-${XFWM4_VERSION}
XFWM4_ENV="$CROSS_ENV_AC"

build_xfwm4() {
    test -e "$STATE_DIR/xfwm4.installed" && return
    banner "Build xfwm4"
    download $XFWM4_MIRROR $XFWM4
    extract $XFWM4
    apply_patches $XFWM4_DIR $XFWM4
    pushd $TOP_DIR
    cd $XFWM4_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFWM4_ENV \
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
    touch "$STATE_DIR/xfwm4.installed"
}

build_xfwm4
