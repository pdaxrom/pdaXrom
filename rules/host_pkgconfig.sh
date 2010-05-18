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

HOST_PKGCONFIG=pkg-config-0.23.tar.gz
HOST_PKGCONFIG_MIRROR=http://pkgconfig.freedesktop.org/releases
HOST_PKGCONFIG_DIR=$HOST_BUILD_DIR/pkg-config-0.23
HOST_PKGCONFIG_ENV=

build_host_pkgconfig() {
    test -e "$STATE_DIR/host_pkgconfig-0.23" && return
    banner "Build $HOST_PKGCONFIG"
    download $HOST_PKGCONFIG_MIRROR $HOST_PKGCONFIG
    extract_host $HOST_PKGCONFIG
    apply_patches $HOST_PKGCONFIG_DIR $HOST_PKGCONFIG
    pushd $TOP_DIR
    cd $HOST_PKGCONFIG_DIR
    eval $HOST_PKGCONFIG_ENV \
	./configure --prefix=$HOST_BIN_DIR || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_pkgconfig-0.23"
}

build_host_pkgconfig
