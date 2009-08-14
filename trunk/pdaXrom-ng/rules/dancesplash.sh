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

DANCESPLASH_VERSION=0.1
DANCESPLASH=dancesplash-${DANCESPLASH_VERSION}.tar.bz2
DANCESPLASH_MIRROR=http://wiki.pdaxrom.org/downloads/PS3/bootloader/src
DANCESPLASH_DIR=$BUILD_DIR/dancesplash-${DANCESPLASH_VERSION}
DANCESPLASH_ENV="$CROSS_ENV_AC"

build_dancesplash() {
    test -e "$STATE_DIR/dancesplash.installed" && return
    banner "Build dancesplash"
    download $DANCESPLASH_MIRROR $DANCESPLASH
    extract $DANCESPLASH
    apply_patches $DANCESPLASH_DIR $DANCESPLASH
    pushd $TOP_DIR
    cd $DANCESPLASH_DIR
    
    make CC=${CROSS}gcc INSTALL=${INSTALL} OPT_LDFLAGS="-L${TARGET_LIB} -Wl,-rpath,${TARGET_LIB} -Wl,-rpath-link,${TARGET_LIB}" || error

    make CC=${CROSS}gcc INSTALL=${INSTALL} DESTDIR=$ROOTFS_DIR install || error

    $STRIP $ROOTFS_DIR/usr/bin/dancesplash || error

    popd
    touch "$STATE_DIR/dancesplash.installed"
}

build_dancesplash
