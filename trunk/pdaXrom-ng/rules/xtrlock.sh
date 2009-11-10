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

XTRLOCK_VERSION=2.0
XTRLOCK=xtrlock_${XTRLOCK_VERSION}-13.tar.gz
XTRLOCK_MIRROR=ftp://ftp.us.debian.org/debian/pool/main/x/xtrlock
XTRLOCK_DIR=$BUILD_DIR/xtrlock-${XTRLOCK_VERSION}
XTRLOCK_ENV="$CROSS_ENV_AC"

build_xtrlock() {
    test -e "$STATE_DIR/xtrlock.installed" && return
    banner "Build xtrlock"
    download $XTRLOCK_MIRROR $XTRLOCK
    extract $XTRLOCK
    apply_patches $XTRLOCK_DIR $XTRLOCK
    pushd $TOP_DIR
    cd $XTRLOCK_DIR

    make -f Makefile.noimake CC=${CROSS}gcc CFLAGS="-O2 -DSHADOW_PWD" LDFLAGS="-Wl,-rpath,${TARGET_LIB} -L${TARGET_LIB} -lX11 -lcrypt" $MAKEARGS || error "build xtrlock"

    $INSTALL -D -m 4755 xtrlock $ROOTFS_DIR/usr/bin/xtrlock

    popd
    touch "$STATE_DIR/xtrlock.installed"
}

build_xtrlock
