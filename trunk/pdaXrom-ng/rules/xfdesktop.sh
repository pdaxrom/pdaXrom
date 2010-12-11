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

XFDESKTOP_VERSION=4.7.4
XFDESKTOP=xfdesktop-${XFDESKTOP_VERSION}.tar.bz2
XFDESKTOP_MIRROR=http://mocha.xfce.org/archive/xfce/4.8pre2/src
XFDESKTOP_DIR=$BUILD_DIR/xfdesktop-${XFDESKTOP_VERSION}
XFDESKTOP_ENV="$CROSS_ENV_AC"

build_xfdesktop() {
    test -e "$STATE_DIR/xfdesktop.installed" && return
    banner "Build xfdesktop"
    download $XFDESKTOP_MIRROR $XFDESKTOP
    extract $XFDESKTOP
    apply_patches $XFDESKTOP_DIR $XFDESKTOP
    pushd $TOP_DIR
    cd $XFDESKTOP_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFDESKTOP_ENV \
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
    touch "$STATE_DIR/xfdesktop.installed"
}

build_xfdesktop
