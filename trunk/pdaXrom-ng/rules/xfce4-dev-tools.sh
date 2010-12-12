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

XFCE4_DEV_TOOLS_VERSION=4.7.3
XFCE4_DEV_TOOLS=xfce4-dev-tools-${XFCE4_DEV_TOOLS_VERSION}.tar.bz2
XFCE4_DEV_TOOLS_MIRROR=http://archive.xfce.org/src/xfce/xfce4-dev-tools/4.7
XFCE4_DEV_TOOLS_DIR=$BUILD_DIR/xfce4-dev-tools-${XFCE4_DEV_TOOLS_VERSION}
XFCE4_DEV_TOOLS_ENV="$CROSS_ENV_AC"

build_xfce4_dev_tools() {
    test -e "$STATE_DIR/xfce4_dev_tools.installed" && return
    banner "Build xfce4-dev-tools"
    download $XFCE4_DEV_TOOLS_MIRROR $XFCE4_DEV_TOOLS
    extract $XFCE4_DEV_TOOLS
    apply_patches $XFCE4_DEV_TOOLS_DIR $XFCE4_DEV_TOOLS
    pushd $TOP_DIR
    cd $XFCE4_DEV_TOOLS_DIR
    (
    eval \
	$CROSS_CONF_ENV \
	$XFCE4_DEV_TOOLS_ENV \
	./configure --build=$BUILD_ARCH --host=$TARGET_ARCH \
	    --prefix=/usr \
	    --sysconfdir=/etc \
	    || error
    ) || error "configure"

    make $MAKEARGS || error

    install_sysroot_files || error

    ln -sf ${TARGET_BIN_DIR}/bin/xdt-autogen ${HOST_BIN_DIR}/bin/xdt-autogen

    #install_fakeroot_init
    #install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/xfce4_dev_tools.installed"
}

build_xfce4_dev_tools
