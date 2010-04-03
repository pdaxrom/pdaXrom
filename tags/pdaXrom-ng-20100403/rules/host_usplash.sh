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

HOST_USPLASH_VERSION=0.5.33
HOST_USPLASH=usplash_${HOST_USPLASH_VERSION}.tar.gz
HOST_USPLASH_MIRROR=http://launchpad.net/ubuntu/karmic/+source/usplash/0.5.33/+files
HOST_USPLASH_DIR=$HOST_BUILD_DIR/ubuntu
HOST_USPLASH_ENV=

build_host_usplash() {
    test -e "$STATE_DIR/host_usplash.installed" && return
    banner "Build host-usplash"
    download $HOST_USPLASH_MIRROR $HOST_USPLASH
    extract_host $HOST_USPLASH
    apply_patches $HOST_USPLASH_DIR $HOST_USPLASH
    pushd $TOP_DIR
    cd $HOST_USPLASH_DIR
    make $MAKEARGS -C bogl bdftobogl pngtobogl || error
    $INSTALL -D -m 755 bogl/bdftobogl $HOST_BIN_DIR/bin/bdftobogl || error
    $INSTALL -D -m 755 bogl/pngtobogl $HOST_BIN_DIR/bin/pngtobogl || error
    $INSTALL -D -m 755 bogl/bdftobogl $HOST_BIN_DIR/bin/bdftousplash || error
    $INSTALL -D -m 755 bogl/pngtobogl $HOST_BIN_DIR/bin/pngtousplash || error

    popd
    touch "$STATE_DIR/host_usplash.installed"
}

build_host_usplash
