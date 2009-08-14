#
# host packet template
#
# Copyright (C) 2008 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_ICON_NAMING_UTILS=icon-naming-utils-0.8.7.tar.gz
HOST_ICON_NAMING_UTILS_MIRROR=http://tango.freedesktop.org/releases
HOST_ICON_NAMING_UTILS_DIR=$HOST_BUILD_DIR/icon-naming-utils-0.8.7
HOST_ICON_NAMING_UTILS_ENV=

build_host_icon_naming_utils() {
    test -e "$STATE_DIR/host_icon_naming_utils.installed" && return
    banner "Build host-icon-naming-utils"
    download $HOST_ICON_NAMING_UTILS_MIRROR $HOST_ICON_NAMING_UTILS
    extract_host $HOST_ICON_NAMING_UTILS
    apply_patches $HOST_ICON_NAMING_UTILS_DIR $HOST_ICON_NAMING_UTILS
    pushd $TOP_DIR
    cd $HOST_ICON_NAMING_UTILS_DIR
    eval $HOST_ICON_NAMING_UTILS_ENV \
	./configure --prefix=$HOST_BIN_DIR \
	    || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_icon_naming_utils.installed"
}

build_host_icon_naming_utils
