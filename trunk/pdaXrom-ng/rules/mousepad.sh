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

MOUSEPAD_VERSION=0.2.16
MOUSEPAD=mousepad-${MOUSEPAD_VERSION}.tar.bz2
MOUSEPAD_MIRROR=http://mocha.xfce.org/archive/xfce/4.6.0/src
MOUSEPAD_DIR=$BUILD_DIR/mousepad-${MOUSEPAD_VERSION}
MOUSEPAD_ENV="$CROSS_ENV_AC"

build_mousepad() {
    test -e "$STATE_DIR/mousepad.installed" && return
    banner "Build mousepad"
    download $MOUSEPAD_MIRROR $MOUSEPAD
    extract $MOUSEPAD
    apply_patches $MOUSEPAD_DIR $MOUSEPAD
    pushd $TOP_DIR
    cd $MOUSEPAD_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$MOUSEPAD_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/mousepad.installed"
}

build_mousepad
