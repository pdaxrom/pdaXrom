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

XFCE_UTILS_VERSION=4.7.3
XFCE_UTILS=xfce-utils-${XFCE_UTILS_VERSION}.tar.bz2
XFCE_UTILS_MIRROR=http://archive.xfce.org/src/xfce/xfce-utils/4.7
XFCE_UTILS_DIR=$BUILD_DIR/xfce-utils-${XFCE_UTILS_VERSION}
XFCE_UTILS_ENV="$CROSS_ENV_AC"

build_xfce_utils() {
    test -e "$STATE_DIR/xfce_utils.installed" && return
    banner "Build xfce-utils"
    download $XFCE_UTILS_MIRROR $XFCE_UTILS
    extract $XFCE_UTILS
    apply_patches $XFCE_UTILS_DIR $XFCE_UTILS
    pushd $TOP_DIR
    cd $XFCE_UTILS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFCE_UTILS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    install_fakeroot_init
    rm -rf fakeroot/usr/lib/xfce4
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/xfce_utils.installed"
}

build_xfce_utils
