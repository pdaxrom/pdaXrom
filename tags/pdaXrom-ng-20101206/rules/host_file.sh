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

HOST_FILE_VERSION=5.03
HOST_FILE=file-${HOST_FILE_VERSION}.tar.gz
HOST_FILE_MIRROR=ftp://ftp.astron.com/pub/file
HOST_FILE_DIR=$HOST_BUILD_DIR/file-${HOST_FILE_VERSION}
HOST_FILE_ENV=

build_host_file() {
    test -e "$STATE_DIR/host_file.installed" && return
    banner "Build host-file"
    download $HOST_FILE_MIRROR $HOST_FILE
    extract_host $HOST_FILE
    apply_patches $HOST_FILE_DIR $HOST_FILE
    pushd $TOP_DIR
    cd $HOST_FILE_DIR
    (
    eval $HOST_FILE_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_file.installed"
}

build_host_file
