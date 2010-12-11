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

TERMINAL_VERSION=0.2.10
TERMINAL=Terminal-${TERMINAL_VERSION}.tar.bz2
TERMINAL_MIRROR=http://mocha.xfce.org/archive/xfce/4.6.0/src
TERMINAL_DIR=$BUILD_DIR/Terminal-${TERMINAL_VERSION}
TERMINAL_ENV="$CROSS_ENV_AC"

build_Terminal() {
    test -e "$STATE_DIR/Terminal.installed" && return
    banner "Build Terminal"
    download $TERMINAL_MIRROR $TERMINAL
    extract $TERMINAL
    apply_patches $TERMINAL_DIR $TERMINAL
    pushd $TOP_DIR
    cd $TERMINAL_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$TERMINAL_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    #install_sysroot_files || error

    install_fakeroot_init

    error "update install"

    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/Terminal.installed"
}

build_Terminal
