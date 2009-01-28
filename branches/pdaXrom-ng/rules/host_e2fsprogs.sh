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

HOST_E2FSPROGS_VERSION=1.41.4
HOST_E2FSPROGS=e2fsprogs-${HOST_E2FSPROGS_VERSION}.tar.gz
HOST_E2FSPROGS_MIRROR=http://prdownloads.sourceforge.net/e2fsprogs
HOST_E2FSPROGS_DIR=$HOST_BUILD_DIR/e2fsprogs-${HOST_E2FSPROGS_VERSION}
HOST_E2FSPROGS_ENV=

build_host_e2fsprogs() {
    test -e "$STATE_DIR/host_e2fsprogs.installed" && return
    banner "Build host-e2fsprogs"
    download $HOST_E2FSPROGS_MIRROR $HOST_E2FSPROGS
    extract_host $HOST_E2FSPROGS
    apply_patches $HOST_E2FSPROGS_DIR $HOST_E2FSPROGS
    pushd $TOP_DIR
    cd $HOST_E2FSPROGS_DIR
    (
    eval $HOST_E2FSPROGS_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make -C lib/uuid $MAKEARGS || error
    make -C lib/uuid $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_e2fsprogs.installed"
}

build_host_e2fsprogs
