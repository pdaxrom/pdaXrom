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

NETCONFIG=netconfig-svn
NETCONFIG_SVN=http://pdaxrom.svn.sourceforge.net/svnroot/pdaxrom/trunk/netconfig
NETCONFIG_DIR=$BUILD_DIR/${NETCONFIG}
NETCONFIG_ENV="$CROSS_ENV_AC"

build_netconfig() {
    test -e "$STATE_DIR/netconfig.installed" && return
    banner "Build netconfig"
    download_svn $NETCONFIG_SVN $NETCONFIG
    cp -R $SRC_DIR/$NETCONFIG $BUILD_DIR
    apply_patches $NETCONFIG_DIR $NETCONFIG
    pushd $TOP_DIR
    cd $NETCONFIG_DIR

    make $MAKEARGS CC=${CROSS}gcc INSTALL=${INSTALL} OPT_LDFLAGS="-Wl,-rpath,${TARGET_LIB}" || error

    install_fakeroot_init
    install_fakeroot_finish || error

    popd
    touch "$STATE_DIR/netconfig.installed"
}

build_netconfig
