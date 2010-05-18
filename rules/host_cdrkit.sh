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

HOST_CDRKIT_VERSION=1.1.10
HOST_CDRKIT=cdrkit-${HOST_CDRKIT_VERSION}.tar.gz
HOST_CDRKIT_MIRROR=http://cdrkit.org/releases
HOST_CDRKIT_DIR=$HOST_BUILD_DIR/cdrkit-${HOST_CDRKIT_VERSION}
HOST_CDRKIT_ENV=

build_host_cdrkit() {
    test -e "$STATE_DIR/host_cdrkit" && return
    banner "Build $HOST_CDRKIT"
    download $HOST_CDRKIT_MIRROR $HOST_CDRKIT
    extract_host $HOST_CDRKIT
    apply_patches $HOST_CDRKIT_DIR $HOST_CDRKIT
    pushd $TOP_DIR
    cd $HOST_CDRKIT_DIR
    make $MAKEARGS || error

    $INSTALL -D -m 755 build/genisoimage/genisoimage $HOST_BIN_DIR/bin/genisoimage
    popd
    touch "$STATE_DIR/host_cdrkit"
}

build_host_cdrkit
