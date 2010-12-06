#
# host packet template
#
# Copyright (C) 2009 by Alexander Chukov <sash@pdaXrom.org>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the pdaXrom project and license conditions
# see the README file.
#

HOST_XZ_VERSION=5.0.0
HOST_XZ=xz-${HOST_XZ_VERSION}.tar.bz2
HOST_XZ_MIRROR=http://tukaani.org/xz
HOST_XZ_DIR=$HOST_BUILD_DIR/xz-${HOST_XZ_VERSION}
HOST_XZ_ENV=

build_host_xz() {
    test -e "$STATE_DIR/host_xz.installed" && return
    banner "Build host-xz"
    download $HOST_XZ_MIRROR $HOST_XZ
    extract_host $HOST_XZ
    apply_patches $HOST_XZ_DIR $HOST_XZ
    pushd $TOP_DIR
    cd $HOST_XZ_DIR
    (
    eval $HOST_XZ_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_xz.installed"
}

build_host_xz
