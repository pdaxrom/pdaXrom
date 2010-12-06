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

HOST_FINDUTILS=findutils-4.4.0.tar.gz
HOST_FINDUTILS_MIRROR=http://ftp.gnu.org/pub/gnu/findutils
HOST_FINDUTILS_DIR=$HOST_BUILD_DIR/findutils-4.4.0
HOST_FINDUTILS_ENV=

build_host_findutils() {
    test -e "$STATE_DIR/host_findutils.installed" && return
    banner "Build host-findutils"
    download $HOST_FINDUTILS_MIRROR $HOST_FINDUTILS
    extract_host $HOST_FINDUTILS
    apply_patches $HOST_FINDUTILS_DIR $HOST_FINDUTILS
    pushd $TOP_DIR
    cd $HOST_FINDUTILS_DIR
    (
    eval $HOST_FINDUTILS_ENV \
	./configure --prefix=$HOST_BIN_DIR
    ) || error
    make $MAKEARGS || error
    make $MAKEARGS install || error
    popd
    touch "$STATE_DIR/host_findutils.installed"
}

build_host_findutils
