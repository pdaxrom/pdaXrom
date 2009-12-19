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

XDOTOOL_VERSION=20091210.01
XDOTOOL=xdotool-${XDOTOOL_VERSION}.tar.gz
XDOTOOL_MIRROR=http://semicomplete.googlecode.com/files
XDOTOOL_DIR=$BUILD_DIR/xdotool-${XDOTOOL_VERSION}
XDOTOOL_ENV="$CROSS_ENV_AC"

build_xdotool() {
    test -e "$STATE_DIR/xdotool.installed" && return
    banner "Build xdotool"
    download $XDOTOOL_MIRROR $XDOTOOL
    extract $XDOTOOL
    apply_patches $XDOTOOL_DIR $XDOTOOL
    pushd $TOP_DIR
    cd $XDOTOOL_DIR

    make $MAKEARGS xdotool CC=${CROSS}gcc LDFLAGS="-Wl,-rpath,${TARGET_LIB} -L${TARGET_LIB} -lX11 -lXtst" || error

    install_rootfs_usr_bin ./xdotool

    popd
    touch "$STATE_DIR/xdotool.installed"
}

build_xdotool
