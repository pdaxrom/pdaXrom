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

SIXAXISD_VERSION=0.1
SIXAXISD=sixaxisd-${SIXAXISD_VERSION}.tar.bz2
SIXAXISD_MIRROR=http://wiki.pdaxrom.org/downloads/PS3/bootloader/src
SIXAXISD_DIR=$BUILD_DIR/sixaxisd-${SIXAXISD_VERSION}
SIXAXISD_ENV="$CROSS_ENV_AC"

build_sixaxisd() {
    test -e "$STATE_DIR/sixaxisd.installed" && return
    banner "Build sixaxisd"
    download $SIXAXISD_MIRROR $SIXAXISD
    extract $SIXAXISD
    apply_patches $SIXAXISD_DIR $SIXAXISD
    pushd $TOP_DIR
    cd $SIXAXISD_DIR
    
    make $MAKEARGS CC=${CROSS}gcc || error

    $INSTALL -D -m 755 sixaxisd $ROOTFS_DIR/usr/bin/sixaxisd || error
    $STRIP $ROOTFS_DIR/usr/bin/sixaxisd || error

    popd
    touch "$STATE_DIR/sixaxisd.installed"
}

build_sixaxisd
