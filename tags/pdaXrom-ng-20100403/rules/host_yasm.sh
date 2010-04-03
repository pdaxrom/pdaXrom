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

HOST_YASM_VERSION=0.8.0
HOST_YASM=yasm-${HOST_YASM_VERSION}.tar.gz
HOST_YASM_MIRROR=http://www.tortall.net/projects/yasm/releases
HOST_YASM_DIR=$HOST_BUILD_DIR/yasm-${HOST_YASM_VERSION}
HOST_YASM_ENV=

build_host_yasm() {
    test -e "$STATE_DIR/host_yasm.installed" && return
    banner "Build host-yasm"
    download $HOST_YASM_MIRROR $HOST_YASM
    extract_host $HOST_YASM
    apply_patches $HOST_YASM_DIR $HOST_YASM
    pushd $TOP_DIR
    cd $HOST_YASM_DIR
    (
    eval $HOST_YASM_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_yasm.installed"
}

build_host_yasm
