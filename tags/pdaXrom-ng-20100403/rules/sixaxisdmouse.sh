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

SIXAXISD=sixaxisd-svn
SIXAXISD_SVN=http://pdaxrom.svn.sourceforge.net/svnroot/pdaxrom/trunk/sixaxisd
SIXAXISD_DIR=$BUILD_DIR/${SIXAXISD}
SIXAXISD_ENV="$CROSS_ENV_AC"

build_sixaxisd() {
    test -e "$STATE_DIR/sixaxisd.installed" && return
    banner "Build sixaxisd"
    download_svn $SIXAXISD_SVN $SIXAXISD
    cp -R $SRC_DIR/$SIXAXISD $SIXAXISD_DIR
    apply_patches $SIXAXISD_DIR $SIXAXISD
    pushd $TOP_DIR
    cd $SIXAXISD_DIR

    make $MAKEARGS CC=${CROSS}gcc || error

    $INSTALL -D -m 755 sixaxisd $ROOTFS_DIR/usr/bin/sixaxisd || error
    $STRIP $ROOTFS_DIR/usr/bin/sixaxisd || error

    $INSTALL -D -m 755 $GENERICFS_DIR/etc/init.d/sixaxismouse $ROOTFS_DIR/etc/init.d/sixaxismouse || error
    install_rc_start sixaxismouse 71
    install_rc_stop  sixaxismouse 19

    rm -f $ROOTFS_DIR/etc/rc.d/*_bluetooth

    popd
    touch "$STATE_DIR/sixaxisd.installed"
}

build_sixaxisd
