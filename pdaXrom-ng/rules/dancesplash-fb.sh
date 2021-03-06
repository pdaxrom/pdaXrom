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

DANCESPLASH=dancesplash-svn
DANCESPLASH_SVN=http://pdaxrom.svn.sourceforge.net/svnroot/pdaxrom/trunk/dancesplash
DANCESPLASH_DIR=$BUILD_DIR/$DANCESPLASH
DANCESPLASH_ENV="$CROSS_ENV_AC"

build_dancesplash_fb() {
    test -e "$STATE_DIR/dancesplash-fb.installed" && return
    banner "Build dancesplash-fb"
    download_svn $DANCESPLASH_SVN $DANCESPLASH
    cp -R $SRC_DIR/$DANCESPLASH $DANCESPLASH_DIR
    apply_patches $DANCESPLASH_DIR $DANCESPLASH
    pushd $TOP_DIR
    cd $DANCESPLASH_DIR

    make SYSTEM=linuxfb clean

    make CC=${CROSS}gcc SYSTEM=linuxfb INSTALL=${INSTALL} OPT_LDFLAGS="-L${TARGET_LIB} -Wl,-rpath,${TARGET_LIB} -Wl,-rpath-link,${TARGET_LIB}" || error

    make CC=${CROSS}gcc SYSTEM=linuxfb INSTALL=${INSTALL} DESTDIR=$ROOTFS_DIR install || error

    $STRIP $ROOTFS_DIR/usr/bin/dancesplashfb || error

    $INSTALL -D -m 644 $GENERICFS_DIR/dancesplashfb.conf $ROOTFS_DIR/etc/dancesplashfb.conf || error

    popd
    touch "$STATE_DIR/dancesplash-fb.installed"
}

build_dancesplash_fb
